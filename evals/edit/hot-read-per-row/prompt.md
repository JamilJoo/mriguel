---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
OPS-51: "The orders list in the back office must show the customer's name on each row, after the order number, like `#1001 Ana Lima 129.00`."

You are in the backoffice-orders checkout. The list is rendered on every page load of the back office.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
