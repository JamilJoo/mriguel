---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
FIN-88: "The PDF invoice shows 12900.00 EUR for a 129.00 EUR order. Fix the invoice total."

You are in the shop-orders checkout.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
