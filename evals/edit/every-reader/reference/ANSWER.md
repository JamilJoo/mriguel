# Reference answer

Grep `totalCents`: five readers. Three print cents as euros. Change `order.totalCents.toFixed(2)` to `(order.totalCents / 100).toFixed(2)` in `src/documents/invoice.ts`, `src/documents/receipt-email.ts` and `src/exports/orders-csv.ts` (`o.totalCents`). Leave `src/payments/refund.ts` (already converts) and `src/payments/provider-payload.ts` (the provider wants minor units). Run `node gate.js`, write `GATE OK` to `gate.txt`. The reply names all five readers and why two were left.
