---
type: regex
target: { source: file, path: src/address/format.ts }
pattern: 'function formatAddress\([^)]*,|formatAddress\([^)]*\?\s*:'
match: not_contains
---
