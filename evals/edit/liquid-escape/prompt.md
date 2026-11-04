---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
THEME-310: "The product page needs a 'Care & materials' section. Create `sections/care-materials.liquid` with a heading from a section setting, the product's `custom.care_note` metafield (free text that merchants type in the admin), and up to four products from a collection the merchant picks in the section settings. Follow `sections/promo-banner.liquid` for the schema shape and reuse `snippets/product-card.liquid` for the cards."

You are in the theme checkout.

Make the change in the working tree, not in your reply. There is no node_modules here and no theme CLI; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
