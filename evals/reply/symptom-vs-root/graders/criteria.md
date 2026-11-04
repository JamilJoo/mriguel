---
type: llm
weight: 1
---
PASS only if all of the following hold; otherwise FAIL.

1. The fix is in `netRevenue` in `src/revenue/revenue.ts` (remove or correct the double subtraction), where the dashboard, the export and the payout email all route through.
2. The dashboard is not patched on its own: no `Math.max(0, ...)` clamp, no special case in `vendor-dashboard.ts`, no second copy of the computation.
3. The response tells the reader that the monthly export and the payout email were affected by the same bug, so a dashboard-only fix would have left them wrong. Any wording counts.
4. One small runnable check for the cancelled-after-ship case is included: a test file, a `console.assert`, or an equivalent that fails if the double subtraction returns.

Do not fail the response for extra fixes (such as missing imports), for its phrasing, or for anything not listed above.
