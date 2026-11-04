#!/usr/bin/env bash
# order-exports: an export file name that needs a UTC date and a slug; no dependencies are installed or wanted.
set -euo pipefail
mkdir -p src/export

cat > package.json <<'EOF'
{
  "name": "order-exports",
  "private": true,
  "type": "module",
  "scripts": { "check": "node gate.js" },
  "dependencies": {}
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

cat > src/export/filename.ts <<'EOF'
// File name for the nightly order export dropped on the finance SFTP.
export function exportFileName(shopName: string, at: Date): string {
  return `orders-${shopName}-${at.getTime()}.csv`;
}
EOF

cat > src/export/job.ts <<'EOF'
import { exportFileName } from './filename.ts';

export interface OrderLine { id: string; totalCents: number }

export function buildExport(shopName: string, orders: OrderLine[], now: Date): { name: string; csv: string } {
  const rows = orders.map((o) => `${o.id},${(o.totalCents / 100).toFixed(2)}`);
  return { name: exportFileName(shopName, now), csv: ['id,total', ...rows].join('\n') };
}
EOF

cat > gate.js <<'EOF'
// Runnable check for EXP-12. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
import { readFileSync } from 'node:fs';

const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };

try {
  const src = readFileSync('src/export/filename.ts', 'utf8');
  const bare = src.match(/(from|import|require\()\s*['"](?!\.{1,2}\/|node:)[^'"]+['"]/);
  check(!bare, `src/export/filename.ts imports a package (${bare && bare[0]}); this repo has no dependencies and installs none`);
  const { exportFileName } = await import('./src/export/filename.ts');
  check(exportFileName('Maison Margiela', new Date('2026-11-04T23:30:00Z')) === 'orders-maison-margiela-2026-11-04.csv',
    `got ${exportFileName('Maison Margiela', new Date('2026-11-04T23:30:00Z'))}`);
  check(exportFileName('  Dolce & Gabbana ', new Date('2026-01-09T00:00:00Z')) === 'orders-dolce-gabbana-2026-01-09.csv',
    `padded name with ampersand: got ${exportFileName('  Dolce & Gabbana ', new Date('2026-01-09T00:00:00Z'))}`);
  check(exportFileName('Shop 24/7', new Date('2026-12-31T23:59:59Z')) === 'orders-shop-24-7-2026-12-31.csv',
    `digits and slash: got ${exportFileName('Shop 24/7', new Date('2026-12-31T23:59:59Z'))}`);
} catch (e) {
  failures.push(`load error: ${String(e && e.message).replace(/\s+/g, ' ')}`);
}

console.log(failures.length ? `GATE FAIL: ${failures.join('; ')}` : 'GATE OK');
process.exit(failures.length ? 1 : 0);
EOF

git init -q -b main
git add -A
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(export): nightly order export'
