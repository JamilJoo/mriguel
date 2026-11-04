---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
SEO-120: "Product URLs come out as `/products/gucci---bag-42` for the title `Gucci - Bag`, and `/products/-sale--42` for ` Sale `. Search Console flags both as duplicates of the clean form. Slugs must collapse runs of dashes and never start or end with one."

You are in the catalog-urls checkout.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
