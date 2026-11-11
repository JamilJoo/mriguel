#!/usr/bin/env bash
# order-documents: Order.totalCents is in minor units. Invoice, receipt email and the CSV export print it as euros
# (wrong); the refund and the payment-provider payload use it correctly. The ticket names the invoice only.
set -euo pipefail
mkdir -p src/orders src/documents src/payments src/exports

cat > package.json <<'EOF2'
{ "name": "order-documents", "private": true, "type": "module", "scripts": { "check": "node gate.js" } }
EOF2

cat > src/orders/order.ts <<'EOF2'
export interface Order {
  id: number;
  email: string;
  /** Order total in minor units (cents). */
  totalCents: number;
}
EOF2

cat > src/documents/invoice.ts <<'EOF2'
import type { Order } from '../orders/order.ts';

export function invoiceTotalLine(order: Order): string {
  return `Total: ${order.totalCents.toFixed(2)} EUR`;
}
EOF2

cat > src/documents/receipt-email.ts <<'EOF2'
import type { Order } from '../orders/order.ts';

export function receiptEmailBody(order: Order): string {
  return `Thank you for order #${order.id}. We charged ${order.totalCents.toFixed(2)} EUR to your card.`;
}
EOF2

cat > src/exports/orders-csv.ts <<'EOF2'
import type { Order } from '../orders/order.ts';

// Monthly export for the accountant: id,email,total in euros with two decimals.
export function ordersCsv(orders: Order[]): string {
  return ['id,email,total_eur', ...orders.map((o) => `${o.id},${o.email},${o.totalCents.toFixed(2)}`)].join('\n');
}
EOF2

cat > src/payments/refund.ts <<'EOF2'
import type { Order } from '../orders/order.ts';

export function refundNotice(order: Order): string {
  return `Refund of ${(order.totalCents / 100).toFixed(2)} EUR issued for order #${order.id}.`;
}
EOF2

cat > src/payments/provider-payload.ts <<'EOF2'
import type { Order } from '../orders/order.ts';

// The payment provider's API takes the amount in minor units.
export function capturePayload(order: Order): { amount_minor: number; currency: string } {
  return { amount_minor: order.totalCents, currency: 'EUR' };
}
EOF2

cat > gate.js <<'EOF2'
// Runnable check for FIN-88. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };
const order = { id: 7, email: 'ana@example.com', totalCents: 12900 };

try {
  const { invoiceTotalLine } = await import('./src/documents/invoice.ts');
  const { refundNotice } = await import('./src/payments/refund.ts');
  check(invoiceTotalLine(order) === 'Total: 129.00 EUR', `invoice: got ${invoiceTotalLine(order)}`);
  check(refundNotice(order) === 'Refund of 129.00 EUR issued for order #7.', `refund: got ${refundNotice(order)}`);
} catch (e) {
  failures.push(`load error: ${String(e && e.message).replace(/\s+/g, ' ')}`);
}

console.log(failures.length ? `GATE FAIL: ${failures.join('; ')}` : 'GATE OK');
process.exit(failures.length ? 1 : 0);
EOF2

git init -q -b main
git add -A
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(orders): invoice, receipt, export, refund and capture'
