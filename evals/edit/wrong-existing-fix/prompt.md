---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
ORD-412 was reopened by Finance: "Invoices still show a negative total when the TEN coupon (10% off) is applied. The checkout summary was fixed last week, but the PDF invoice shows -900.00 for a 100.00 order."

You are in the checkout-service checkout. Last week's change is the ORD-412 note in `src/checkout/summary.ts`. The repro test `src/pricing/discount.test.ts` fails right now.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
