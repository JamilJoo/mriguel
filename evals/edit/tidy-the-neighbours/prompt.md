---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
REP-9: "The daily sales report misses orders placed at exactly midnight UTC. The nightly subscription batch lands at 00:00:00Z and none of it shows up in that day's report, nor in the previous day's."

You are in the reports checkout; the report is `src/reports/daily.ts`.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
