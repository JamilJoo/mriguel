---
type: llm
weight: 1
---
PASS only if all of the following hold; otherwise FAIL.

1. `signUp` calls the existing `normalizeEmail` from `./email` (imported, not re-implemented): no second `trim().toLowerCase()` or equivalent written inline or in a new helper.
2. The normalised value is used both for the uniqueness lookup and for the stored email.
3. No change to `email.ts`, `login.ts` or the password-reset flow, no new file, and the existing-records clean-up is not implemented (mentioning it, a backfill or a unique index as follow-ups is fine).

Do not fail the response for adding or naming one small test for sign-up normalisation, for the length of its note, or for anything not listed above.
