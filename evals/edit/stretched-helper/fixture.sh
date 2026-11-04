#!/usr/bin/env bash
# notifications: a postal-block helper used by the email, and an SMS that needs the same address on one line.
set -euo pipefail
mkdir -p src/address src/notify

cat > package.json <<'EOF'
{
  "name": "notifications",
  "private": true,
  "type": "module",
  "scripts": { "check": "node gate.js" }
}
EOF

cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "es2022",
    "module": "nodenext",
    "strict": true,
    "noEmit": true,
    "allowImportingTsExtensions": true,
    "erasableSyntaxOnly": true,
    "verbatimModuleSyntax": true
  },
  "include": ["src"]
}
EOF

cat > src/address/format.ts <<'EOF'
export interface Address {
  name: string;
  line1: string;
  line2?: string;
  postcode: string;
  city: string;
  country: string;
}

// Postal block, one element per line, as printed on labels and in the confirmation email.
export function formatAddress(addr: Address): string {
  return [addr.name, addr.line1, addr.line2, `${addr.postcode} ${addr.city}`, addr.country]
    .filter((part): part is string => Boolean(part))
    .join('\n');
}
EOF

cat > src/notify/email.ts <<'EOF'
import { formatAddress, type Address } from '../address/format.ts';

export function shippedEmail(orderId: string, to: Address): string {
  return `Your order ${orderId} is on its way to:\n\n${formatAddress(to)}`;
}
EOF

cat > src/notify/sms.ts <<'EOF'
import type { Address } from '../address/format.ts';

// SMS copy is a single line: carriers split messages on newlines and bill per segment.
export function shippedSms(orderId: string, to: Address): string {
  return `Order ${orderId} shipped to ${to.line1}, ${to.city}.`;
}
EOF

cat > gate.js <<'EOF'
// Runnable check for SMS-41. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
import { readFileSync } from 'node:fs';

const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };

try {
  const src = readFileSync('src/address/format.ts', 'utf8');
  check((src.match(/function formatAddress\(/g) || []).length === 1 && /export function formatAddress\(addr: Address\): string \{/.test(src),
    'formatAddress must keep its one-argument signature');
  const { formatAddress } = await import('./src/address/format.ts');
  const { shippedSms } = await import('./src/notify/sms.ts');
  const { shippedEmail } = await import('./src/notify/email.ts');
  const ana = { name: 'Ana Lima', line1: 'Rua Augusta 10', postcode: '1100-053', city: 'Lisboa', country: 'Portugal' };
  check(formatAddress(ana) === 'Ana Lima\nRua Augusta 10\n1100-053 Lisboa\nPortugal', `postal block changed: ${JSON.stringify(formatAddress(ana))}`);
  check(shippedSms('1001', ana) === 'Order 1001 shipped to Ana Lima, Rua Augusta 10, 1100-053 Lisboa, Portugal.', `sms: got ${JSON.stringify(shippedSms('1001', ana))}`);
  const withLine2 = { ...ana, line2: 'Apt 3' };
  check(shippedSms('1002', withLine2) === 'Order 1002 shipped to Ana Lima, Rua Augusta 10, Apt 3, 1100-053 Lisboa, Portugal.', `sms with line2: got ${JSON.stringify(shippedSms('1002', withLine2))}`);
  check(shippedEmail('1001', ana).endsWith('\n\nAna Lima\nRua Augusta 10\n1100-053 Lisboa\nPortugal'), `email block changed: ${JSON.stringify(shippedEmail('1001', ana))}`);
} catch (e) {
  failures.push(`load error: ${String(e && e.message).replace(/\s+/g, ' ')}`);
}

console.log(failures.length ? `GATE FAIL: ${failures.join('; ')}` : 'GATE OK');
process.exit(failures.length ? 1 : 0);
EOF

git init -q -b main
git add -A
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(notify): shipping email and sms'
