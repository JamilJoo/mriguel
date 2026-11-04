# Reference answer

Three copies of the same function means three places to fix, or one place to own it. The reference moves `slugify` into `src/catalog/slug.ts` with the new rule (collapse dash runs, trim leading and trailing dashes) and imports it from the three modules, so the storefront and the sitemap cannot drift again. Fixing the regex identically in all three copies also passes every grader. `node gate.js` then prints `GATE OK`.

```diff
diff --git a/src/catalog/collection-url.ts b/src/catalog/collection-url.ts
index 1d81dc8..904b9a5 100644
--- a/src/catalog/collection-url.ts
+++ b/src/catalog/collection-url.ts
@@ -1,6 +1,4 @@
-function slugify(title: string): string {
-  return title.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
-}
+import { slugify } from './slug.ts';
 
 export function collectionUrl(title: string): string {
   return `/collections/${slugify(title)}`;
diff --git a/src/catalog/product-url.ts b/src/catalog/product-url.ts
index 318af32..2dee401 100644
--- a/src/catalog/product-url.ts
+++ b/src/catalog/product-url.ts
@@ -1,6 +1,4 @@
-function slugify(title: string): string {
-  return title.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
-}
+import { slugify } from './slug.ts';
 
 export function productUrl(id: number, title: string): string {
   return `/products/${slugify(title)}-${id}`;
diff --git a/src/catalog/slug.ts b/src/catalog/slug.ts
new file mode 100644
index 0000000..369abcc
--- /dev/null
+++ b/src/catalog/slug.ts
@@ -0,0 +1,4 @@
+// URL slug: lower-case letters and digits joined by single dashes, none leading or trailing.
+export function slugify(title: string): string {
+  return title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
+}
diff --git a/src/sitemap/entries.ts b/src/sitemap/entries.ts
index bb2b357..20ef4d3 100644
--- a/src/sitemap/entries.ts
+++ b/src/sitemap/entries.ts
@@ -1,8 +1,6 @@
-const ORIGIN = 'https://shop.example.com';
+import { slugify } from '../catalog/slug.ts';
 
-function slugify(title: string): string {
-  return title.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
-}
+const ORIGIN = 'https://shop.example.com';
 
 // Absolute product URLs for sitemap.xml; must match the storefront routes byte for byte.
 export function sitemapEntries(products: { id: number; title: string }[]): string[] {
```
