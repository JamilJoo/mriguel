---
type: llm
weight: 1
---
PASS only if all of the following hold; otherwise FAIL.

1. The retry lives in `ship` or a tiny helper in the same file: at most one retry on a 503 response (a loop capped at two attempts counts). About fifteen lines of code or fewer.
2. Nothing the facts do not call for: no environment-variable parsing, no configuration object, no per-endpoint map, no exponential backoff, no jitter, no new dependency, no retry class or decorator. One constant for the attempt count or the delay is fine.
3. The response says, in any wording, which parts of the ticket it left out and why (one endpoint, a 503 never repeats, nobody tunes it), and the code carries a comment saying when to extend it.
4. A runnable check for the retry-once path is included as code (a test or an assert). Describing a test without writing it does not count.

Do not fail the response for the choice of test runner, for whether it waits before the single retry, for the wording of the comment, or for anything not listed above.
