---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---
Bug report from support: "The vendor dashboard shows negative revenue for shop LDN this month. It happens when an order is cancelled after it was shipped. Please fix the dashboard."

Reply with the code change (changed lines per file) and a short note.

Files:

src/revenue/revenue.ts
```ts
export interface Row { gross: number; refunded: number; cancelledAfterShip: boolean }
/** Net revenue of a set of order rows. Used by the vendor dashboard, the monthly export and the payout email. */
export function netRevenue(rows: Row[]): number {
  let net = 0;
  for (const r of rows) {
    net += r.gross - r.refunded;
    if (r.cancelledAfterShip) net -= r.gross; // cancellation after shipping
  }
  return net;
}
```

src/dashboard/vendor-dashboard.ts
```ts
import { netRevenue } from '../revenue/revenue';
export function dashboardRevenue(rows: Row[]): number { return netRevenue(rows); }
```

src/exports/monthly-export.ts
```ts
import { netRevenue } from '../revenue/revenue';
export function exportRevenue(rows: Row[]): number { return netRevenue(rows); }
```
Fact: for an order cancelled after shipping, the refund is already recorded in `refunded` (equal to `gross`), so the cancellation line subtracts the same money a second time.
