---
type: regex
target: { source: file, path: gate.js }
pattern: 'expectQty\(''2 x 6'', 12\);'
match: "count:1"
---
