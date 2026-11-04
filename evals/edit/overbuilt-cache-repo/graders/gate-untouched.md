---
type: regex
target: { source: file, path: gate.js }
pattern: 'check\(stats\.reads === 1, '
match: "count:1"
---
