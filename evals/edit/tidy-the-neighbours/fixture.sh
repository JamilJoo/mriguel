#!/usr/bin/env bash
# reports: an old-style report module with a boundary bug (> instead of >=) surrounded by code that begs for a tidy-up.
set -euo pipefail
mkdir -p src/reports

cat > package.json <<'EOF'
{
  "name": "reports",
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

cat > src/reports/format.ts <<'EOF'
export const money = (cents: number): string => (cents / 100).toFixed(2);
EOF

cat > src/reports/daily.ts <<'EOF'
import { money } from './format.ts';

export interface Order { id: string; placedAt: string; totalCents: number; status: 'paid' | 'refunded' | 'cancelled' }

// const old_cutoff = 1000 * 60 * 60 * 24;
var DAY_MS = 86400000;

export function dailyReport(orders: Order[], day: string): string {
  const start = Date.parse(day + 'T00:00:00Z');
  const end   = start + DAY_MS;
  var tmp2 = [];
  for( var i = 0; i < orders.length; i++ ){
    const o = orders[i];
    const t = Date.parse(o.placedAt);
    // if (o.status == 'refunded') continue;
    if( t > start && t < end && o.status === 'paid' ){ tmp2.push(o); }
  }
  const sum = calc_Stuff(tmp2);
  return `${day}: ${tmp2.length} orders, ${money(sum)}`;
}

function calc_Stuff(list: Order[]): number {
  var s = 0;
  for( var i = 0; i < list.length; i++ ){ s += list[i].totalCents; }
  return s;
}
EOF

cat > gate.js <<'EOF'
// Runnable check for REP-9. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };

try {
  const { dailyReport } = await import('./src/reports/daily.ts');
  const orders = [
    { id: 'a', placedAt: '2026-11-03T00:00:00Z', totalCents: 5000, status: 'paid' },
    { id: 'b', placedAt: '2026-11-03T23:59:59Z', totalCents: 10000, status: 'paid' },
    { id: 'c', placedAt: '2026-11-04T00:00:00Z', totalCents: 7000, status: 'paid' },
    { id: 'd', placedAt: '2026-11-03T12:00:00Z', totalCents: 9000, status: 'refunded' },
  ];
  check(dailyReport(orders, '2026-11-03') === '2026-11-03: 2 orders, 150.00', `3 Nov: expected "2026-11-03: 2 orders, 150.00", got "${dailyReport(orders, '2026-11-03')}"`);
  check(dailyReport(orders, '2026-11-04') === '2026-11-04: 1 orders, 70.00', `4 Nov: expected "2026-11-04: 1 orders, 70.00", got "${dailyReport(orders, '2026-11-04')}"`);
  check(dailyReport(orders, '2026-11-02') === '2026-11-02: 0 orders, 0.00', `2 Nov: expected no orders, got "${dailyReport(orders, '2026-11-02')}"`);
} catch (e) {
  failures.push(`load error: ${String(e && e.message).replace(/\s+/g, ' ')}`);
}

console.log(failures.length ? `GATE FAIL: ${failures.join('; ')}` : 'GATE OK');
process.exit(failures.length ? 1 : 0);
EOF

git init -q -b main
git add -A
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(reports): daily sales report'
