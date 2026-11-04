# Reference answer

A module-level `Map` keyed by id with a short TTL, in the service file: hits return the entry, misses read the database and store the result. The comment names the ceiling (one process; Redis only if the service scales out) so nobody has to rediscover it. No interface, no adapter, no configuration, no new file. `node gate.js` then prints `GATE OK`.

```diff
diff --git a/src/products/product.service.ts b/src/products/product.service.ts
index c673c9c..8107ece 100644
--- a/src/products/product.service.ts
+++ b/src/products/product.service.ts
@@ -2,6 +2,15 @@ import { db, type ProductRow } from '../db.ts';
 
 export type Product = ProductRow;
 
+// In-memory cache for one process: a product changes a few times a day and a read costs about 40 ms.
+// Ceiling: a second instance would serve stale data for up to TTL_MS; move the map to Redis if the API scales out.
+const TTL_MS = 5 * 60 * 1000;
+const cached = new Map<string, { product: Product | null; expiresAt: number }>();
+
 export async function getProduct(id: string): Promise<Product | null> {
-  return db.product.findUnique({ where: { id } });
+  const hit = cached.get(id);
+  if (hit && hit.expiresAt > Date.now()) return hit.product;
+  const product = await db.product.findUnique({ where: { id } });
+  cached.set(id, { product, expiresAt: Date.now() + TTL_MS });
+  return product;
 }
```
