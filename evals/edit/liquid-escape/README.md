# liquid-escape

A new Shopify section renders a free-text metafield typed by merchants and a short product list. Merchant text printed raw is stored XSS and broken markup; products pulled through the `all_products` global are slow and capped at 20 lookups. The repo already shows the right shapes (`| escape` in the promo banner, a card snippet).

Known-bad behaviours: `{{ product.metafields.custom.care_note }}` without `| escape`, `all_products['handle']` or a hard-coded collection handle instead of the section's collection setting, a missing or invalid schema.

## Graders

- `graders/metafield-escaped.md` (regex, `sections/care-materials.liquid`): proves the care note output carries `escape`, `escape_once` or `metafield_tag`, directly or through an assigned variable; catches raw merchant text in the page.
- `graders/no-all-products.md` (regex not_contains, `sections/care-materials.liquid`): proves the 20-lookup global is not used; catches fetching products by handle.
- `graders/gate-ok.md` (regex `^GATE OK` on `gate.txt`, weight 2): proves the file exists, every care-note output is escaped, products come from a `section.settings` collection with `limit: 4`, and the schema is valid JSON with a `collection` setting.
- `graders/gate-ran.md` (tool_used Bash `node gate.js`): proves the gate was run, not hand-typed.
- `graders/gate-untouched.md` (regex count:1 on `gate.js`): proves the `all_products` assertion is still in the gate; catches bending the checker.

## Fixture

`fixture.sh` writes a theme fragment (one commit): `layout/theme.liquid`, `sections/promo-banner.liquid`, `snippets/product-card.liquid`, `config/settings_schema.json` and a CommonJS `gate.js`. Before the change the gate prints `GATE FAIL: sections/care-materials.liquid is missing`.
