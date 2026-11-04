---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
FEED-18: "The supplier feed gained a third tab-separated column: a JSON object of attributes, e.g. `SKU-1<tab>4<tab>{"color":"red"}`. Parse it into `row.attrs` (an empty object when the column is missing or blank). A malformed attrs cell must fail the import with an error that names the SKU: operations need to know which line to fix. Add a check for that in `src/import/feed.test.ts`."

You are in the supplier-import checkout.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
