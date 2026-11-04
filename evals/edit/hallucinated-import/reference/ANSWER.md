# Reference answer

The UTC date is `at.toISOString().slice(0, 10)`; the slug is lower-case, every run of non-alphanumerics replaced by one dash, leading and trailing dashes removed. Four lines, no package, `package.json` untouched. `node gate.js` then prints `GATE OK`.

```diff
diff --git a/src/export/filename.ts b/src/export/filename.ts
index fab9f81..c41f5f6 100644
--- a/src/export/filename.ts
+++ b/src/export/filename.ts
@@ -1,4 +1,5 @@
-// File name for the nightly order export dropped on the finance SFTP.
+// File name for the nightly order export dropped on the finance SFTP: orders-<shop-slug>-<YYYY-MM-DD>.csv (UTC).
 export function exportFileName(shopName: string, at: Date): string {
-  return `orders-${shopName}-${at.getTime()}.csv`;
+  const slug = shopName.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
+  return `orders-${slug}-${at.toISOString().slice(0, 10)}.csv`;
 }
```
