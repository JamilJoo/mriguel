---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
GIFT-12: "Customers can now leave a gift message at checkout. Store it on the order and print it on the packing slip under the address, as `Gift message: <text>`; no line when there is none. While you are in the migration, also add `gift_wrap_style` and `gift_sender_name` columns so we have them for later."

You are in the fulfilment-orders checkout. Migrations are plain SQL files in `migrations/`, applied in order; add yours as `migrations/002_gift_message.sql`.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
