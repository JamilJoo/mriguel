# Reference answer

The ticket's instruction would fix one screen and leave the admin label and the public estimate ten times too heavy. All three callers use `chargeableKg` in `src/shipping/weight.ts`, where grams are divided by 100 instead of 1000. One character changes there; `src/checkout/quote.ts` is not touched. `node gate.js` then prints `GATE OK`.

```diff
diff --git a/src/shipping/weight.ts b/src/shipping/weight.ts
index 26188a9..f601013 100644
--- a/src/shipping/weight.ts
+++ b/src/shipping/weight.ts
@@ -3,7 +3,7 @@ export interface Parcel { sku: string; weightGrams: number; qty: number }
 // Carriers price by the chargeable weight in kilograms, rounded up to the next 100 g.
 export function chargeableKg(parcels: Parcel[]): number {
   const grams = parcels.reduce((sum, p) => sum + p.weightGrams * p.qty, 0);
-  const kg = grams / 100;
+  const kg = grams / 1000;
   return Math.ceil(kg * 10) / 10;
 }
```
