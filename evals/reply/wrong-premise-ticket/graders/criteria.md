---
type: llm
weight: 1
---
PASS only if all of the following hold; otherwise FAIL.

1. The response does not convert the date to DD/MM/YYYY or any non-ISO format; it says, with the carrier reference and the stored error as evidence, that the format was never the problem.
2. The response identifies the real cause from the stored response: the date is computed from the server's UTC day while the carrier checks the pickup location's local day (UTC+9), so a date that is "today" in UTC can already be "yesterday" there.
3. The proposed change computes the pickup date in the pickup location's timezone (or otherwise guarantees today-or-later in that timezone), in `buildPickupRequest` or the code that feeds it, keeping ISO YYYY-MM-DD output.
4. One small test or check for the timezone boundary is included or named explicitly.

Do not fail the response for the exact timezone library or method used, for its wording, or for anything not listed above.
