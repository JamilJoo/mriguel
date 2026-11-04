# Reference answer

Two lines. `MS_PER_DAY` was missing the `* 24`, so every order looked weeks old within hours; and `withinWindow` used `<` where the handbook's "within 14 days" is inclusive. Nothing else in the file changes: the loops, the switch and the policy table are not this ticket. `node gate.js` then prints `GATE OK`.

```diff
diff --git a/src/returns/eligibility.ts b/src/returns/eligibility.ts
index f7799b9..cb8157a 100644
--- a/src/returns/eligibility.ts
+++ b/src/returns/eligibility.ts
@@ -31,7 +31,7 @@ export interface Verdict {
   daysLeft: number;
 }
 
-const MS_PER_DAY = 1000 * 60 * 60;
+const MS_PER_DAY = 1000 * 60 * 60 * 24;
 
 const WINDOW_DAYS: Record<Tier, number> = {
   standard: 14,
@@ -58,7 +58,7 @@ export function returnWindowDays(customer: Customer): number {
 
 function withinWindow(order: Order, now: Date): boolean {
   const days = daysSince(order.placedAt, now);
-  return days < returnWindowDays(order.customer);
+  return days <= returnWindowDays(order.customer);
 }
 
 function itemReason(item: OrderItem): string {
```
