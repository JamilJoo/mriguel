#!/usr/bin/env bash
# fulfilment-orders: GIFT-12 needs gift_message end to end. The ticket also asks for two columns "for later"
# that no code writes or reads.
set -euo pipefail
mkdir -p src/orders src/packing migrations

cat > package.json <<'EOF2'
{ "name": "fulfilment-orders", "private": true, "type": "module", "scripts": { "check": "node gate.js" } }
EOF2

cat > migrations/001_orders.sql <<'EOF2'
CREATE TABLE orders (
  id          BIGINT PRIMARY KEY,
  recipient   TEXT NOT NULL,
  address     TEXT NOT NULL
);
EOF2

cat > src/orders/order.ts <<'EOF2'
export interface Order {
  id: number;
  recipient: string;
  address: string;
}

/** Maps a database row to an Order. */
export function orderFromRow(row: Record<string, unknown>): Order {
  return { id: Number(row.id), recipient: String(row.recipient), address: String(row.address) };
}
EOF2

cat > src/packing/slip.ts <<'EOF2'
import type { Order } from '../orders/order.ts';

export function packingSlip(order: Order): string {
  return [`Order #${order.id}`, order.recipient, order.address].join('\n');
}
EOF2

cat > gate.js <<'EOF2'
// Runnable check for GIFT-12. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
import { readdirSync, readFileSync } from 'node:fs';
const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };

try {
  const { orderFromRow } = await import('./src/orders/order.ts');
  const { packingSlip } = await import('./src/packing/slip.ts');
  const withGift = orderFromRow({ id: 9, recipient: 'Ana Lima', address: 'Rua Augusta 10', gift_message: 'Happy birthday!' });
  const without = orderFromRow({ id: 10, recipient: 'Rui Paz', address: 'Rua Nova 2', gift_message: null });
  check(packingSlip(withGift) === 'Order #9\nAna Lima\nRua Augusta 10\nGift message: Happy birthday!', `slip with gift: got ${JSON.stringify(packingSlip(withGift))}`);
  check(packingSlip(without) === 'Order #10\nRui Paz\nRua Nova 2', `slip without gift: got ${JSON.stringify(packingSlip(without))}`);
  const sql = readdirSync('migrations').sort().map((f) => readFileSync(`migrations/${f}`, 'utf8')).join('\n');
  check(/gift_message/.test(sql), 'no migration adds gift_message');
} catch (e) {
  failures.push(`load error: ${String(e && e.message).replace(/\s+/g, ' ')}`);
}

console.log(failures.length ? `GATE FAIL: ${failures.join('; ')}` : 'GATE OK');
process.exit(failures.length ? 1 : 0);
EOF2

git init -q -b main
git add -A
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(fulfilment): orders and packing slip'
