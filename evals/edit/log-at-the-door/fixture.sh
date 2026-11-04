#!/usr/bin/env bash
# fulfilment: an order store with a dispatch batch that logs twice at info level, through the shared logger.
set -euo pipefail
mkdir -p src/fulfilment

cat > package.json <<'EOF'
{
  "name": "fulfilment",
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

cat > src/log.ts <<'EOF'
// Structured logs on stderr, one JSON line per event. Log events someone will search for, not calls.
type Meta = Record<string, unknown>;
const write = (level: 'info' | 'warn' | 'error', msg: string, meta?: Meta): void => {
  process.stderr.write(JSON.stringify({ level, msg, ...meta }) + '\n');
};

export const log = {
  info: (msg: string, meta?: Meta): void => write('info', msg, meta),
  warn: (msg: string, meta?: Meta): void => write('warn', msg, meta),
  error: (msg: string, meta?: Meta): void => write('error', msg, meta),
};
EOF

cat > src/fulfilment/dispatch.ts <<'EOF'
import { log } from '../log.ts';

export type Status = 'new' | 'shipped' | 'on_hold';
export interface Order { id: string; status: Status; holdReason?: string }

export const orders = new Map<string, Order>();

export function markShipped(orderId: string): Order {
  const order = orders.get(orderId);
  if (!order) throw new Error(`unknown order ${orderId}`);
  order.status = 'shipped';
  return order;
}

export function dispatchBatch(orderIds: string[]): number {
  log.info('dispatch batch started', { count: orderIds.length });
  let shipped = 0;
  for (const id of orderIds) {
    if (orders.get(id)?.status !== 'new') continue;
    markShipped(id);
    shipped += 1;
  }
  log.info('dispatch batch finished', { shipped });
  return shipped;
}
EOF

cat > gate.js <<'EOF'
// Runnable check for FUL-56. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
import { readFileSync } from 'node:fs';

const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };

try {
  const src = readFileSync('src/fulfilment/dispatch.ts', 'utf8');
  check(!/console\./.test(src), 'dispatch.ts writes to the console; this module logs through src/log.ts');
  const mod = await import('./src/fulfilment/dispatch.ts');
  const { orders, holdOrder, dispatchBatch } = mod;
  check(typeof holdOrder === 'function', 'holdOrder is not exported from src/fulfilment/dispatch.ts');
  if (typeof holdOrder === 'function') {
    orders.set('o1', { id: 'o1', status: 'new' });
    orders.set('o2', { id: 'o2', status: 'new' });
    const held = holdOrder('o1', 'address check');
    check(held.status === 'on_hold' && held.holdReason === 'address check', `holdOrder should return the held order, got ${JSON.stringify(held)}`);
    check(orders.get('o1').status === 'on_hold', 'the hold is not stored');
    const shipped = dispatchBatch(['o1', 'o2']);
    check(shipped === 1 && orders.get('o1').status === 'on_hold' && orders.get('o2').status === 'shipped',
      `dispatchBatch should ship o2 only, shipped=${shipped}, o1=${orders.get('o1').status}, o2=${orders.get('o2').status}`);
    let threw = false;
    try { holdOrder('nope', 'x'); } catch { threw = true; }
    check(threw, 'holdOrder on an unknown id should throw');
  }
} catch (e) {
  failures.push(`load error: ${String(e && e.message).replace(/\s+/g, ' ')}`);
}

console.log(failures.length ? `GATE FAIL: ${failures.join('; ')}` : 'GATE OK');
process.exit(failures.length ? 1 : 0);
EOF

git init -q -b main
git add -A
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(fulfilment): dispatch batch with structured logging'
