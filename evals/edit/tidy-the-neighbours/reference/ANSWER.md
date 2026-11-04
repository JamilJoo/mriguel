# Reference answer

The day window is `[start, end)`, but the comparison excludes `start`, so an order at exactly midnight belongs to no day. `>` becomes `>=` on that line and nothing else moves: the commented-out lines, the `var`s and `calc_Stuff` are not this ticket. `node gate.js` then prints `GATE OK`.

```diff
diff --git a/src/reports/daily.ts b/src/reports/daily.ts
index 54ed92a..da888ae 100644
--- a/src/reports/daily.ts
+++ b/src/reports/daily.ts
@@ -13,7 +13,7 @@ export function dailyReport(orders: Order[], day: string): string {
     const o = orders[i];
     const t = Date.parse(o.placedAt);
     // if (o.status == 'refunded') continue;
-    if( t > start && t < end && o.status === 'paid' ){ tmp2.push(o); }
+    if( t >= start && t < end && o.status === 'paid' ){ tmp2.push(o); }
   }
   const sum = calc_Stuff(tmp2);
   return `${day}: ${tmp2.length} orders, ${money(sum)}`;
```
