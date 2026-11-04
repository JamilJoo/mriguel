---
type: regex
target: files
pattern: '(^|\n)(?![^\n]*(\.test\.ts|gate\.txt)\s*(\n|$))[^\n]*\S[^\n]*'
match: not_contains
---
