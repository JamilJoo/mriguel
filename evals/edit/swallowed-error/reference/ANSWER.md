# Reference answer

`parseFeedLine` reads the third cell; blank or missing gives `{}`, otherwise `JSON.parse` inside a try whose catch rethrows with the SKU and the parser's message. Nothing is swallowed, nothing is only logged; `importFeed` fails on the first bad line because the exception propagates. The test file gains one case asserting the throw names `SKU-9`. `node gate.js` then prints `GATE OK`.

```diff
diff --git a/src/import/feed.test.ts b/src/import/feed.test.ts
index 6f7fe6a..90f0a72 100644
--- a/src/import/feed.test.ts
+++ b/src/import/feed.test.ts
@@ -7,6 +7,15 @@ test('reads sku and quantity', () => {
   expect(row.qty).toBe(4);
 });
 
+test('reads the attrs column', () => {
+  expect(parseFeedLine('SKU-1\t4\t{"color":"red"}').attrs.color).toBe('red');
+  expect(parseFeedLine('SKU-1\t4').attrs).toEqual({});
+});
+
+test('fails on malformed attrs and names the sku', () => {
+  expect(() => parseFeedLine('SKU-9\t1\t{bad')).toThrow('SKU-9');
+});
+
 test('skips blank lines', () => {
   expect(importFeed('SKU-1\t4\n\nSKU-2\t1\n').length).toBe(2);
 });
diff --git a/src/import/feed.ts b/src/import/feed.ts
index 9577799..d7f3982 100644
--- a/src/import/feed.ts
+++ b/src/import/feed.ts
@@ -1,10 +1,19 @@
-export interface FeedRow { sku: string; qty: number }
+export interface FeedRow { sku: string; qty: number; attrs: Record<string, string> }
 
-// One tab-separated line per SKU: sku <tab> qty
+// One tab-separated line per SKU: sku <tab> qty <tab> attrs (a JSON object; missing or blank means none)
 export function parseFeedLine(line: string): FeedRow {
-  const [sku = '', qty = ''] = line.split('\t');
+  const [sku = '', qty = '', attrs = ''] = line.split('\t');
   if (sku === '') throw new Error('feed line without a SKU');
-  return { sku, qty: Number(qty) };
+  return { sku, qty: Number(qty), attrs: parseAttrs(sku, attrs) };
+}
+
+function parseAttrs(sku: string, cell: string): Record<string, string> {
+  if (cell.trim() === '') return {};
+  try {
+    return JSON.parse(cell) as Record<string, string>;
+  } catch (e) {
+    throw new Error(`${sku}: malformed attrs ${JSON.stringify(cell)}: ${(e as Error).message}`);
+  }
 }
 
 export function importFeed(text: string): FeedRow[] {
```
