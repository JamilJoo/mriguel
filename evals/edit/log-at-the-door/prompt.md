---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
FUL-56: "Add `holdOrder(orderId, reason)` to `src/fulfilment/dispatch.ts`. It puts the order on hold in the store (`status: 'on_hold'` plus the reason) and returns the updated order; an unknown id throws, like `markShipped` does. `dispatchBatch` must leave held orders alone."

You are in the fulfilment checkout.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
