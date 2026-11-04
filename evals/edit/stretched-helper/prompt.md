---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
SMS-41: "The shipping SMS must carry the full delivery address on one line, comma separated, like `Order 1001 shipped to Ana Lima, Rua Augusta 10, 1100-053 Lisboa, Portugal.` Today it only shows the street and the city. The confirmation email keeps its postal block exactly as it is."

You are in the notifications checkout.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
