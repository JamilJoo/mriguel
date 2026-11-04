---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
Ticket: "The carrier API sometimes answers 503 once and then works. Add a retry policy to the carrier client with exponential backoff, jitter, a configurable maximum number of attempts, and per-endpoint overrides via environment variables."

Facts: production logs show the 503 about twice a day and never twice in a row; `ship` in `src/carrier/carrier-client.ts` is the only carrier call in the codebase; there is one endpoint; nobody has asked to tune anything at runtime. Put a runnable check for the retry in `src/carrier/carrier-client.test.ts` (`src/carrier/labels.test.ts` shows the harness; stub `globalThis.fetch` in the test).

You are in the carrier-client checkout.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
