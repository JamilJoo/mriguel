# Reference answer

`ship` sends the request, and if the answer is a 503 it sends it once more; any other failure throws as before. One constant for the retried status, no delay, no configuration: the 503 never repeats and nobody tunes it, and the comment says when to extend it. The test stubs `globalThis.fetch` to answer 503 then 200 and asserts the shipment comes back after two calls. `node gate.js` then prints `GATE OK`.

```diff
diff --git a/src/carrier/carrier-client.test.ts b/src/carrier/carrier-client.test.ts
new file mode 100644
index 0000000..321f193
--- /dev/null
+++ b/src/carrier/carrier-client.test.ts
@@ -0,0 +1,11 @@
+import { test, expect } from '../../test/harness.ts';
+import { ship } from './carrier-client.ts';
+
+test('retries once after a 503', async () => {
+  const answers = [new Response('busy', { status: 503 }), Response.json({ shipmentId: 'shp_1', label: 'PDF' })];
+  let calls = 0;
+  globalThis.fetch = async () => { calls += 1; return answers.shift() as Response; };
+  const shipment = await ship({ orderId: 'o1', weightGrams: 300 });
+  expect(shipment.shipmentId).toBe('shp_1');
+  expect(calls).toBe(2);
+});
diff --git a/src/carrier/carrier-client.ts b/src/carrier/carrier-client.ts
index f6ff598..06828a7 100644
--- a/src/carrier/carrier-client.ts
+++ b/src/carrier/carrier-client.ts
@@ -1,4 +1,7 @@
 const CARRIER_URL = 'https://api.carrier.example';
+// The carrier answers 503 about twice a day and never twice in a row, so one immediate retry covers it.
+// Extend to a loop with a delay only if the logs start showing consecutive 503s.
+const RETRY_STATUS = 503;
 
 export interface ShipRequest { orderId: string; weightGrams: number }
 export interface ShipResponse { shipmentId: string; label: string }
@@ -11,8 +14,12 @@ export class CarrierError extends Error {
   }
 }
 
+const post = (payload: ShipRequest): Promise<Response> =>
+  fetch(`${CARRIER_URL}/ship`, { method: 'POST', body: JSON.stringify(payload) });
+
 export async function ship(payload: ShipRequest): Promise<ShipResponse> {
-  const res = await fetch(`${CARRIER_URL}/ship`, { method: 'POST', body: JSON.stringify(payload) });
+  let res = await post(payload);
+  if (res.status === RETRY_STATUS) res = await post(payload);
   if (!res.ok) throw new CarrierError(res.status, await res.text());
   return (await res.json()) as ShipResponse;
 }
```
