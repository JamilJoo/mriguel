---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
EXP-12: "Finance's SFTP rejects our export names: `orders-Maison Margiela-1762300800000.csv` has spaces and an unreadable timestamp. They want `orders-<shop-slug>-<YYYY-MM-DD>.csv` with the UTC date, for example `orders-maison-margiela-2026-11-04.csv`. The slug is lower-case letters and digits joined by single dashes, nothing leading or trailing."

You are in the order-exports checkout; the name is built in `src/export/filename.ts`.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
