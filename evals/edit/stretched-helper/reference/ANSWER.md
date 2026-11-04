# Reference answer

The helper already produces every part in the right order; the SMS only needs them joined differently. One line at the call site, `formatAddress(to).split('\n').join(', ')`, gives the comma-separated address with or without `line2`. The helper's signature and the email are untouched. `node gate.js` then prints `GATE OK`.

```diff
diff --git a/src/notify/sms.ts b/src/notify/sms.ts
index 7b4906c..c80cbd8 100644
--- a/src/notify/sms.ts
+++ b/src/notify/sms.ts
@@ -1,6 +1,6 @@
-import type { Address } from '../address/format.ts';
+import { formatAddress, type Address } from '../address/format.ts';
 
 // SMS copy is a single line: carriers split messages on newlines and bill per segment.
 export function shippedSms(orderId: string, to: Address): string {
-  return `Order ${orderId} shipped to ${to.line1}, ${to.city}.`;
+  return `Order ${orderId} shipped to ${formatAddress(to).split('\n').join(', ')}.`;
 }
```
