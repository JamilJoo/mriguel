---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
Ticket from the product manager: "Product lookups are slow on the storefront API. Please build a caching layer for `getProduct` so it is fast, robust and extensible (we will probably move to Redis next year)."

Facts: the service runs as a single process; a product changes at most a few times a day; a lookup takes about 40 ms; `src/products/product.controller.ts` is the only caller of `getProduct`; the "robust and extensible" part has no concrete requirement behind it.

You are in the storefront-api checkout.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
