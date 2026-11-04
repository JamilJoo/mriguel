# Reference answer

One new section file in the shape of `promo-banner.liquid`: a heading setting, the metafield printed through `| escape` (merchant text is untrusted), and a `for` over `section.settings.collection.products` with `limit: 4` rendering the existing card snippet. The schema declares the heading and a `collection` setting and a preset so the merchant can add it. Nothing else in the theme changes. `node gate.js` then prints `GATE OK`.

```diff
diff --git a/sections/care-materials.liquid b/sections/care-materials.liquid
new file mode 100644
index 0000000..a6b9cef
--- /dev/null
+++ b/sections/care-materials.liquid
@@ -0,0 +1,25 @@
+{%- comment -%} Care & materials: the merchant-written care note plus a short list of related products. {%- endcomment -%}
+<section class="care-materials">
+  <h2 class="care-materials__heading">{{ section.settings.heading | escape }}</h2>
+  {%- if product.metafields.custom.care_note != blank -%}
+    <p class="care-materials__note">{{ product.metafields.custom.care_note | escape }}</p>
+  {%- endif -%}
+  {%- if section.settings.collection != blank -%}
+    <div class="care-materials__products">
+      {%- for item in section.settings.collection.products limit: 4 -%}
+        {% render 'product-card', product: item %}
+      {%- endfor -%}
+    </div>
+  {%- endif -%}
+</section>
+
+{% schema %}
+{
+  "name": "Care & materials",
+  "settings": [
+    { "type": "text", "id": "heading", "label": "Heading", "default": "Care & materials" },
+    { "type": "collection", "id": "collection", "label": "Related products" }
+  ],
+  "presets": [{ "name": "Care & materials" }]
+}
+{% endschema %}
```
