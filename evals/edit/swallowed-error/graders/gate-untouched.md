---
type: regex
target: { source: file, path: gate.js }
pattern: 'check\(message !== null && message\.includes\(''SKU-9''\), '
match: "count:1"
---
