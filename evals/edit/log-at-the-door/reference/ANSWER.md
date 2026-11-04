# Reference answer

`holdOrder` mirrors `markShipped`: look the order up, throw on an unknown id, set `status` and `holdReason`, return it. `dispatchBatch` already ships only `new` orders, so held ones are left alone without any change there. No log line: nothing here is an event anyone will search for, and the file's two info lines stay as they are. `node gate.js` then prints `GATE OK`.

```diff
diff --git a/src/fulfilment/dispatch.ts b/src/fulfilment/dispatch.ts
index 63d63ac..982a1a6 100644
--- a/src/fulfilment/dispatch.ts
+++ b/src/fulfilment/dispatch.ts
@@ -12,6 +12,14 @@ export function markShipped(orderId: string): Order {
   return order;
 }
 
+export function holdOrder(orderId: string, reason: string): Order {
+  const order = orders.get(orderId);
+  if (!order) throw new Error(`unknown order ${orderId}`);
+  order.status = 'on_hold';
+  order.holdReason = reason;
+  return order;
+}
+
 export function dispatchBatch(orderIds: string[]): number {
   log.info('dispatch batch started', { count: orderIds.length });
   let shipped = 0;
```
