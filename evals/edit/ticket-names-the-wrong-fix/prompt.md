---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
SHIP-233: "Checkout shows 3.0 kg and 12.90 EUR shipping for a single 300 g t-shirt. In `src/checkout/quote.ts`, divide the weight by 10 before pricing: the carrier wants kilograms and we seem to be passing hectograms."

You are in the shipping-quotes checkout.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
