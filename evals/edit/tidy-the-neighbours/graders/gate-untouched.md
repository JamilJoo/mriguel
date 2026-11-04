---
type: regex
target: { source: file, path: gate.js }
pattern: 'check\(dailyReport\(orders, ''2026-11-03''\) === ''2026-11-03: 2 orders, 150\.00'', '
match: "count:1"
---
