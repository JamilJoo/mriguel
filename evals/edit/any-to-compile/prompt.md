---
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash]
---
DELIV-77: "The carrier now sends a `delivered` event and we drop it. Handle it in `parseCarrierEvent` (`src/webhooks/carrier.ts`). The body looks like `{"kind":"delivered","data":{"order_id":"o_123","delivered_at":"2026-11-03T10:15:00Z","signed_by":"J. Doe"}}`; `signed_by` is optional. Return `{ kind: 'delivered', orderId, deliveredAt, signedBy? }`. Anything malformed returns null, as today."

You are in the webhooks checkout. The project compiles with `strict: true` and the body comes straight from `JSON.parse`, so it is typed `unknown`.

Make the change in the working tree, not in your reply. There is no node_modules here; the only runnable check is `node gate.js`, which prints one line. When you are done, run it and write that line into `gate.txt` at the repo root, then reply in a few lines with what you changed.
