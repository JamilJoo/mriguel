---
type: regex
target: { source: file, path: gate.js }
pattern: 'check\(!/all_products/\.test\(src\), '
match: "count:1"
---
