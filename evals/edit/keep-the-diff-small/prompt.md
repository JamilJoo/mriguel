---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
RET-204: "The returns portal refuses almost everything. A bag ordered ten days ago gets 'return window closed' although the policy is 14 days (30 for VIP). Customer care also confirmed that an order placed exactly 14 days ago must still be eligible: the handbook says 'within 14 days', inclusive."

You are in the returns checkout; the logic is in `src/returns/eligibility.ts`.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
