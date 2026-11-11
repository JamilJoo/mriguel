#!/usr/bin/env bash
# backoffice-orders: ordersList() is the hot read. db.ts counts queries and already offers a batch lookup;
# bench.js prints the query count for a 200-order page. The lean-looking change calls getCustomer() per row.
set -euo pipefail
mkdir -p src/db src/orders

cat > package.json <<'EOF2'
{ "name": "backoffice-orders", "private": true, "type": "module", "scripts": { "check": "node gate.js", "bench": "node bench.js" } }
EOF2

cat > README.md <<'EOF2'
# backoffice-orders

`ordersList()` renders the orders table; it runs on every page load of the back office.

- `node gate.js`: the one runnable check.
- `node bench.js`: prints how many database queries one 200-order page costs. Every query is a network round trip of about 15 ms in production.
EOF2

cat > src/db/db.ts <<'EOF2'
export interface OrderRow { id: number; customerId: number; totalCents: number }
export interface CustomerRow { id: number; name: string }

const customers = new Map<number, CustomerRow>();
const orders: OrderRow[] = [];
export const stats = { queries: 0 };

export function seed(n: number): void {
  customers.clear();
  orders.length = 0;
  stats.queries = 0;
  for (let i = 1; i <= n; i++) {
    customers.set(i, { id: i, name: i === 1 ? 'Ana Lima' : `Customer ${i}` });
    orders.push({ id: 1000 + i, customerId: i, totalCents: 12900 });
  }
}

export async function getOrders(): Promise<OrderRow[]> {
  stats.queries++;
  return orders.slice();
}

export async function getCustomer(id: number): Promise<CustomerRow | undefined> {
  stats.queries++;
  return customers.get(id);
}

export async function getCustomersByIds(ids: number[]): Promise<Map<number, CustomerRow>> {
  stats.queries++;
  return new Map(ids.flatMap((id) => (customers.has(id) ? [[id, customers.get(id)!] as const] : [])));
}
EOF2

cat > src/orders/list.ts <<'EOF2'
import { getOrders } from '../db/db.ts';

export async function ordersList(): Promise<string[]> {
  const orders = await getOrders();
  return orders.map((o) => `#${o.id} ${(o.totalCents / 100).toFixed(2)}`);
}
EOF2

cat > bench.js <<'EOF2'
// `node bench.js` prints the number of database queries one 200-order page costs.
const { seed, stats } = await import('./src/db/db.ts');
const { ordersList } = await import('./src/orders/list.ts');
seed(200);
await ordersList();
console.log(`queries for a 200-order page: ${stats.queries}`);
EOF2

cat > gate.js <<'EOF2'
// Runnable check for OPS-51. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };

try {
  const { seed } = await import('./src/db/db.ts');
  const { ordersList } = await import('./src/orders/list.ts');
  seed(3);
  const rows = await ordersList();
  check(rows[0] === '#1001 Ana Lima 129.00', `row 1: got ${rows[0]}`);
  check(rows[2] === '#1003 Customer 3 129.00', `row 3: got ${rows[2]}`);
} catch (e) {
  failures.push(`load error: ${String(e && e.message).replace(/\s+/g, ' ')}`);
}

console.log(failures.length ? `GATE FAIL: ${failures.join('; ')}` : 'GATE OK');
process.exit(failures.length ? 1 : 0);
EOF2

git init -q -b main
git add -A
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(orders): back-office orders list'
