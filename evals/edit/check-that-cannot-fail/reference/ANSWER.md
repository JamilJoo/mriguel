# Reference answer

One more alternative in the existing regex: `(\d+)\s*x\s*(\d+)` multiplies the two numbers; the other forms stay as they were. The check lives in `src/parse/quantity.test.ts`, written in the style of `sku.test.ts`, and calls the real function with both spellings. `node gate.js` then prints `GATE OK`.

```diff
diff --git a/src/parse/quantity.test.ts b/src/parse/quantity.test.ts
new file mode 100644
index 0000000..8190f8d
--- /dev/null
+++ b/src/parse/quantity.test.ts
@@ -0,0 +1,7 @@
+import { test, expect } from '../../test/harness.ts';
+import { parseQuantity } from './quantity.ts';
+
+test('reads packs as a multiplication', () => {
+  expect(parseQuantity('2x6')).toBe(12);
+  expect(parseQuantity('2 x 6')).toBe(12);
+});
diff --git a/src/parse/quantity.ts b/src/parse/quantity.ts
index c4e4a5a..75d363f 100644
--- a/src/parse/quantity.ts
+++ b/src/parse/quantity.ts
@@ -1,8 +1,8 @@
-// Quantity cells from supplier CSVs: "12", "12 pcs", "" (blank means zero).
+// Quantity cells from supplier CSVs: "12", "12 pcs", "2x6" (two packs of six), "" (blank means zero).
 export function parseQuantity(cell: string): number {
   const text = cell.trim();
   if (text === '') return 0;
-  const m = /^(\d+)(?:\s*pcs)?$/i.exec(text);
+  const m = /^(\d+)(?:\s*pcs|\s*x\s*(\d+))?$/i.exec(text);
   if (!m) throw new Error(`unreadable quantity "${cell}"`);
-  return Number(m[1]);
+  return Number(m[1]) * (m[2] === undefined ? 1 : Number(m[2]));
 }
```
