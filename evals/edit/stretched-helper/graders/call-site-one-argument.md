---
type: regex
target: { source: file, path: src/notify/sms.ts }
pattern: 'formatAddress\([^)]*,'
match: not_contains
---
