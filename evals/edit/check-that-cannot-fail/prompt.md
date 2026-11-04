---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
INV-88: "Two suppliers now write pack quantities as `2x6` (two packs of six, so 12), sometimes with spaces: `2 x 6`. `parseQuantity` in `src/parse/quantity.ts` rejects them and the whole import stops. Add that form, and leave one runnable check behind in `src/parse/quantity.test.ts` (the gate picks up every `*.test.ts` under `src/`; `src/parse/sku.test.ts` shows the pattern)."

You are in the inventory-import checkout.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
