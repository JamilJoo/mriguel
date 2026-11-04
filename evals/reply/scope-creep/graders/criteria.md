---
type: llm
weight: 1
---
PASS only if all of the following hold; otherwise FAIL.

1. The loader now reads the YAML key `feed.refreshIntervalMinutes` with the default 30 kept. Renaming the TypeScript field `refreshMinutes` as well is acceptable but not required; if it is renamed, `isStale` must follow.
2. Nothing outside the rename is edited: the unused `Logger` import stays, the `url` typing stays, and no docstrings, comments, reformatting or reordering are added to untouched lines.
3. The unused import and the `url` typing are not fixed; mentioning them as follow-ups is fine.

Do not fail the response for a fallback to the old key that it only suggests, for its wording, or for anything not listed above.
