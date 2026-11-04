---
type: regex
target: { source: file, path: gate.js }
pattern: 'check\(checkReturn\(exactly14, ''BAG-1'', now\)\.eligible === true, '
match: "count:1"
---
