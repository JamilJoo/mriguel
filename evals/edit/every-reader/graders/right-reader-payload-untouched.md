---
type: regex
target: { source: file, path: src/payments/provider-payload.ts }
pattern: 'amount_minor: order\.totalCents,'
match: "count:1"
---
