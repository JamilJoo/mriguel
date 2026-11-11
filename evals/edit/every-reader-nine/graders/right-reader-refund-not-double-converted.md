---
type: regex
target: { source: file, path: src/payments/refund.ts }
pattern: '\/\s*100\s*\)?\s*\/\s*100|\/\s*10000'
match: not_contains
---
