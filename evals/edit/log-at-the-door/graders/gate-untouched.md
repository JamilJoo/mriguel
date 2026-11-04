---
type: regex
target: { source: file, path: gate.js }
pattern: 'check\(held\.status === ''on_hold'' && held\.holdReason === ''address check'', '
match: "count:1"
---
