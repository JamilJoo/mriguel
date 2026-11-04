---
type: regex
target: { source: file, path: gate.js }
pattern: 'check\(priceWithVat\(0\.07, 0\.19\) === 0\.08, '
match: "count:1"
---
