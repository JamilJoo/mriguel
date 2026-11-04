---
type: regex
target: { source: file, path: gate.js }
pattern: 'check\(safe\(\{ kind: ''delivered'', data: \{ order_id: 42 \} \}\) === null, '
match: "count:1"
---
