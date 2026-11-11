---
type: regex
target: { source: file, path: gate.js }
pattern: 'check\(/gift_message/\.test\(sql\), '
match: "count:1"
---
