# Reference answer

The `shipped` branch already shows the pattern: check each field with `typeof` on the `unknown` data and build the typed event. The `delivered` branch does the same for `order_id` and `delivered_at`, adds `signedBy` only when `signed_by` is a string, and the union type gains the new member. No cast, no assertion, no ts-ignore. `node gate.js` then prints `GATE OK`.

```diff
diff --git a/src/webhooks/carrier.ts b/src/webhooks/carrier.ts
index dc0edc9..5f8b2ef 100644
--- a/src/webhooks/carrier.ts
+++ b/src/webhooks/carrier.ts
@@ -1,6 +1,7 @@
 // Carrier webhooks arrive as JSON.parse output: the body is unknown until each field has been checked.
 export type CarrierEvent =
-  | { kind: 'shipped'; orderId: string; trackingNumber: string };
+  | { kind: 'shipped'; orderId: string; trackingNumber: string }
+  | { kind: 'delivered'; orderId: string; deliveredAt: string; signedBy?: string };
 
 type Dict = Record<string, unknown>;
 const isDict = (v: unknown): v is Dict => typeof v === 'object' && v !== null;
@@ -11,5 +12,13 @@ export function parseCarrierEvent(body: unknown): CarrierEvent | null {
   if (body.kind === 'shipped' && typeof data.order_id === 'string' && typeof data.tracking_number === 'string') {
     return { kind: 'shipped', orderId: data.order_id, trackingNumber: data.tracking_number };
   }
+  if (body.kind === 'delivered' && typeof data.order_id === 'string' && typeof data.delivered_at === 'string') {
+    return {
+      kind: 'delivered',
+      orderId: data.order_id,
+      deliveredAt: data.delivered_at,
+      ...(typeof data.signed_by === 'string' ? { signedBy: data.signed_by } : {}),
+    };
+  }
   return null;
 }
```
