#!/usr/bin/env bash
# webhooks: a carrier webhook parser over an unknown-typed body, with one event handled by proper narrowing.
set -euo pipefail
mkdir -p src/webhooks

cat > package.json <<'EOF'
{
  "name": "webhooks",
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

cat > src/webhooks/carrier.ts <<'EOF'
// Carrier webhooks arrive as JSON.parse output: the body is unknown until each field has been checked.
export type CarrierEvent =
  | { kind: 'shipped'; orderId: string; trackingNumber: string };

type Dict = Record<string, unknown>;
const isDict = (v: unknown): v is Dict => typeof v === 'object' && v !== null;

export function parseCarrierEvent(body: unknown): CarrierEvent | null {
  if (!isDict(body) || !isDict(body.data)) return null;
  const data = body.data;
  if (body.kind === 'shipped' && typeof data.order_id === 'string' && typeof data.tracking_number === 'string') {
    return { kind: 'shipped', orderId: data.order_id, trackingNumber: data.tracking_number };
  }
  return null;
}
EOF

cat > src/webhooks/handler.ts <<'EOF'
import { parseCarrierEvent } from './carrier.ts';

export const seen: string[] = [];

// HTTP layer: the raw body is parsed here and handed over untyped.
export function handleCarrierWebhook(rawBody: string): number {
  let parsed: unknown;
  try { parsed = JSON.parse(rawBody); } catch { return 400; }
  const event = parseCarrierEvent(parsed);
  if (!event) return 422;
  seen.push(`${event.kind}:${event.orderId}`);
  return 204;
}
EOF

cat > gate.js <<'EOF'
// Runnable check for DELIV-77. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
import { readFileSync } from 'node:fs';

const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };

try {
  const src = readFileSync('src/webhooks/carrier.ts', 'utf8');
  const hatch = /(:\s*|as\s+|<|,\s*)any\b|@ts-ignore|@ts-expect-error|eslint-disable|as unknown as|[\w)\]]!\s*[.[]/;
  check(!hatch.test(src), `src/webhooks/carrier.ts uses a type escape hatch: ${JSON.stringify((src.match(hatch) || [''])[0])}`);
  const { parseCarrierEvent } = await import('./src/webhooks/carrier.ts');
  const safe = (body) => { try { return parseCarrierEvent(body); } catch (e) { return `throw: ${e.message}`; } };
  const full = safe({ kind: 'delivered', data: { order_id: 'o_123', delivered_at: '2026-11-03T10:15:00Z', signed_by: 'J. Doe' } });
  check(full && full.kind === 'delivered' && full.orderId === 'o_123' && full.deliveredAt === '2026-11-03T10:15:00Z' && full.signedBy === 'J. Doe',
    `delivered with signature: got ${JSON.stringify(full)}`);
  const unsigned = safe({ kind: 'delivered', data: { order_id: 'o_124', delivered_at: '2026-11-03T11:00:00Z' } });
  check(unsigned && unsigned.kind === 'delivered' && unsigned.orderId === 'o_124' && unsigned.signedBy === undefined, `delivered without signature: got ${JSON.stringify(unsigned)}`);
  check(safe({ kind: 'delivered', data: { order_id: 42 } }) === null, 'delivered with a numeric order_id and no delivered_at should be null');
  check(safe({ kind: 'delivered' }) === null, 'delivered without data should be null');
  check(safe('delivered') === null && safe(null) === null, 'a non-object body should be null');
  const shipped = safe({ kind: 'shipped', data: { order_id: 'o_1', tracking_number: 'TRK1' } });
  check(shipped && shipped.kind === 'shipped' && shipped.trackingNumber === 'TRK1', `shipped still parses: got ${JSON.stringify(shipped)}`);
} catch (e) {
  failures.push(`load error: ${String(e && e.message).replace(/\s+/g, ' ')}`);
}

console.log(failures.length ? `GATE FAIL: ${failures.join('; ')}` : 'GATE OK');
process.exit(failures.length ? 1 : 0);
EOF

git init -q -b main
git add -A
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(webhooks): parse the carrier shipped event'
