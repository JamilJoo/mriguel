#!/usr/bin/env bash
# theme: a small Shopify theme fragment with one existing section (escaped output, schema) and a product card snippet.
set -euo pipefail
mkdir -p layout sections snippets config

cat > layout/theme.liquid <<'EOF'
<!doctype html>
<html lang="{{ request.locale.iso_code }}">
<head>
  <meta charset="utf-8">
  <title>{{ page_title | escape }}</title>
  {{ content_for_header }}
</head>
<body>
  {% sections 'header-group' %}
  <main>{{ content_for_layout }}</main>
</body>
</html>
EOF

cat > sections/promo-banner.liquid <<'EOF'
{%- comment -%} Promo banner: merchant text shown above the collection grid. {%- endcomment -%}
<div class="promo-banner">
  <p class="promo-banner__text">{{ section.settings.text | escape }}</p>
  {%- if section.settings.link != blank -%}
    <a class="promo-banner__link" href="{{ section.settings.link }}">{{ section.settings.link_label | escape }}</a>
  {%- endif -%}
</div>

{% schema %}
{
  "name": "Promo banner",
  "settings": [
    { "type": "text", "id": "text", "label": "Text", "default": "Free shipping over 200 EUR" },
    { "type": "url", "id": "link", "label": "Link" },
    { "type": "text", "id": "link_label", "label": "Link label", "default": "Shop now" }
  ],
  "presets": [{ "name": "Promo banner" }]
}
{% endschema %}
EOF

cat > snippets/product-card.liquid <<'EOF'
{%- comment -%} Usage: {% render 'product-card', product: product %} {%- endcomment -%}
<a class="product-card" href="{{ product.url }}">
  {%- if product.featured_image -%}
    <img src="{{ product.featured_image | image_url: width: 480 }}" alt="{{ product.featured_image.alt | escape }}" loading="lazy" width="480" height="600">
  {%- endif -%}
  <span class="product-card__title">{{ product.title | escape }}</span>
  <span class="product-card__price">{{ product.price | money }}</span>
</a>
EOF

cat > config/settings_schema.json <<'EOF'
[
  { "name": "theme_info", "theme_name": "Atelier", "theme_version": "1.4.0", "theme_author": "In-house" }
]
EOF

cat > gate.js <<'EOF'
// Runnable check for THEME-310. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
const fs = require('node:fs');

const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };
const file = 'sections/care-materials.liquid';
let src = '';
try { src = fs.readFileSync(file, 'utf8'); } catch { failures.push(`${file} is missing`); }

if (src) {
  const assigned = [...src.matchAll(/\{%-?\s*assign\s+(\w+)\s*=\s*product\.metafields\.custom\.care_note/g)].map((m) => m[1]);
  const outputs = [...src.matchAll(/\{\{-?\s*([\s\S]*?)\s*-?\}\}/g)].map((m) => m[1]);
  const noteOutputs = outputs.filter((o) => /metafields\.custom\.care_note/.test(o) || assigned.some((v) => new RegExp(`^${v}\\b`).test(o)));
  check(noteOutputs.length > 0, 'the custom.care_note metafield is not rendered');
  for (const o of noteOutputs) check(/\|\s*(escape|escape_once|metafield_tag)\b/.test(o), `merchant text rendered without escaping: {{ ${o} }}`);
  check(!/all_products/.test(src), 'all_products is used; read the products from the collection setting instead');
  check(/section\.settings\.\w+/.test(src) && /\.products\b/.test(src), 'products are not read from a collection in the section settings');
  check(/limit:\s*4\b/.test(src), 'the product loop is not limited to 4');
  const schema = src.match(/\{%-?\s*schema\s*-?%\}([\s\S]*?)\{%-?\s*endschema\s*-?%\}/);
  check(Boolean(schema), 'schema block missing');
  if (schema) {
    try {
      const parsed = JSON.parse(schema[1]);
      check(Array.isArray(parsed.settings) && parsed.settings.some((s) => s.type === 'collection'), 'the schema has no collection setting');
    } catch { failures.push('the schema block is not valid JSON'); }
  }
}

console.log(failures.length ? `GATE FAIL: ${failures.join('; ')}` : 'GATE OK');
process.exit(failures.length ? 1 : 0);
EOF

git init -q -b main
git add -A
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(theme): promo banner section and product card snippet'
