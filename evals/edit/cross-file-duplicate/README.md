# cross-file-duplicate

`slugify` was copy-pasted into the product URL, the collection URL and the sitemap modules. The ticket describes product URLs only; the sitemap must match the storefront byte for byte, so fixing one copy breaks the site map and leaves collections wrong.

Known-bad behaviours: fixing only `product-url.ts`; fixing two of the three; introducing a shared helper but leaving a copy behind.

## Graders

- `graders/new-behaviour-product-url.md` (regex, `src/catalog/product-url.ts`): proves the dash-collapsing/trimming behaviour (or an import of a shared slug module) is in the product URL module.
- `graders/new-behaviour-collection-url.md` (regex, `src/catalog/collection-url.ts`): same proof for the collection URL module; catches fixing the named file only.
- `graders/new-behaviour-sitemap.md` (regex, `src/sitemap/entries.ts`): same proof for the sitemap; catches a storefront/sitemap mismatch.
- `graders/gate-ok.md` (regex `^GATE OK` on `gate.txt`, weight 2): proves all three entry points produce clean slugs for padded, double-dashed and ampersand titles; catches a regex that collapses but does not trim.
- `graders/gate-ran.md` (tool_used Bash `node gate.js`): proves the gate was run, not hand-typed.
- `graders/gate-untouched.md` (regex count:1 on `gate.js`): proves the collection assertion is still in the gate; catches bending the checker.

Each per-file regex accepts the common spellings (`/-+/g`, `/-{2,}/g`, `/--+/g`, `/^-|-$/g`, `split/filter(Boolean)/join`, `match(/[a-z0-9]+/g)`) and an import from a module whose path contains `slug`, so consolidating the three copies into one shared module also passes.

## Fixture

`fixture.sh` writes the catalog-urls repo (one commit) with the three modules and `gate.js`. Before the change the gate prints `GATE FAIL: product: got /products/gucci---bag-42; ...`.
