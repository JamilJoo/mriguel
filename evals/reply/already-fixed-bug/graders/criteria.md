---
type: llm
weight: 1
---
PASS only if all of the following hold; otherwise FAIL.

1. No code change is proposed to `formatNote` or its tests: no second null check, no optional chaining added, no new guard.
2. The response states that the reported bug is already fixed on main and names the evidence (the existing `note == null` guard and its tests, the deployed commit, the clean error log).
3. The response says what to do with the report in a sentence (close it, or reply to support), and does not invent a different bug to fix.

Do not fail the response for its wording, for suggesting the report be closed, or for anything not listed above.
