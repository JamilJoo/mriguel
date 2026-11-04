# Reference answer

Last week's clamp in `src/checkout/summary.ts` hid the symptom in one caller. The fault is `applyDiscount` in `src/pricing/discount.ts`: it multiplies the amount by the whole-number percent (`cents * 10`) where it needs `cents * 10 / 100`. Every caller routes through that function, so the one-line change there fixes the invoice, the summary and the repro test at once. The clamp is now dead and goes with it; the test file is untouched. `node gate.js` then prints `GATE OK`.

```diff
diff --git a/src/checkout/summary.ts b/src/checkout/summary.ts
index f2b1847..c183247 100644
--- a/src/checkout/summary.ts
+++ b/src/checkout/summary.ts
@@ -9,6 +9,5 @@ export function subtotalCents(lines: Line[]): number {
 export function summaryTotalCents(lines: Line[], coupon?: Coupon): number {
   const subtotal = subtotalCents(lines);
   if (!coupon) return subtotal;
-  // ORD-412: a coupon could push the total below zero; never show a negative amount.
-  return Math.max(0, applyDiscount(subtotal, coupon.percentOff));
+  return applyDiscount(subtotal, coupon.percentOff);
 }
diff --git a/src/pricing/discount.ts b/src/pricing/discount.ts
index f698f26..54e3fbf 100644
--- a/src/pricing/discount.ts
+++ b/src/pricing/discount.ts
@@ -2,5 +2,5 @@
 export interface Coupon { code: string; percentOff: number }
 
 export function applyDiscount(cents: number, percentOff: number): number {
-  return cents - Math.round(cents * percentOff);
+  return cents - Math.round((cents * percentOff) / 100);
 }
```
