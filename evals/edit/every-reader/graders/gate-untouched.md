---
type: regex
target: { source: file, path: gate.js }
pattern: 'check\(invoiceTotalLine\(order\) === ''Total: 129\.00 EUR'', '
match: "count:1"
---
