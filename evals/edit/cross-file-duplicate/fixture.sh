#!/usr/bin/env bash
# catalog-urls: slugify() was copy-pasted into three modules; the ticket only mentions product URLs.
set -euo pipefail
mkdir -p src/catalog src/sitemap

cat > package.json <<'EOF'
{
  "name": "catalog-urls",
  "private": true,
  "type": "module",
  "scripts": { "check": "node gate.js" }
}
EOF

cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "es2022",
    "module": "nodenext",
    "strict": true,
    "noEmit": true,
    "allowImportingTsExtensions": true,
    "erasableSyntaxOnly": true,
    "verbatimModuleSyntax": true
  },
  "include": ["src"]
}
EOF

cat > src/catalog/product-url.ts <<'EOF'
function slugify(title: string): string {
  return title.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
}

export function productUrl(id: number, title: string): string {
  return `/products/${slugify(title)}-${id}`;
}
EOF

cat > src/catalog/collection-url.ts <<'EOF'
function slugify(title: string): string {
  return title.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
}

export function collectionUrl(title: string): string {
  return `/collections/${slugify(title)}`;
}
EOF

cat > src/sitemap/entries.ts <<'EOF'
const ORIGIN = 'https://shop.example.com';

function slugify(title: string): string {
  return title.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
}

// Absolute product URLs for sitemap.xml; must match the storefront routes byte for byte.
export function sitemapEntries(products: { id: number; title: string }[]): string[] {
  return products.map((p) => `${ORIGIN}/products/${slugify(p.title)}-${p.id}`);
}
EOF

cat > gate.js <<'EOF'
// Runnable check for SEO-120. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };

try {
  const { productUrl } = await import('./src/catalog/product-url.ts');
  const { collectionUrl } = await import('./src/catalog/collection-url.ts');
  const { sitemapEntries } = await import('./src/sitemap/entries.ts');
  check(productUrl(42, 'Gucci - Bag') === '/products/gucci-bag-42', `product: got ${productUrl(42, 'Gucci - Bag')}`);
  check(productUrl(42, ' Sale ') === '/products/sale-42', `product with padding: got ${productUrl(42, ' Sale ')}`);
  check(collectionUrl(' Winter -- Sale ') === '/collections/winter-sale', `collection: got ${collectionUrl(' Winter -- Sale ')}`);
  const entries = sitemapEntries([{ id: 7, title: ' Dolce & Gabbana  Belt ' }]);
  check(entries[0] === 'https://shop.example.com/products/dolce-gabbana-belt-7', `sitemap: got ${entries[0]}`);
} catch (e) {
  failures.push(`load error: ${String(e && e.message).replace(/\s+/g, ' ')}`);
}

console.log(failures.length ? `GATE FAIL: ${failures.join('; ')}` : 'GATE OK');
process.exit(failures.length ? 1 : 0);
EOF

git init -q -b main
git add -A
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(catalog): product, collection and sitemap urls'
