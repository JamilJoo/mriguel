---
type: llm
weight: 1
---
PASS only if all of the following hold; otherwise FAIL.

1. The only code change is `DEFAULT_PAGE_SIZE = 24`; `pageSize` and `MAX_PAGE_SIZE` are unchanged.
2. No test file, configuration, environment variable or new helper is added for this change.

Do not fail the response for the length or wording of its note, for caveats it mentions without implementing, or for anything not listed above.
