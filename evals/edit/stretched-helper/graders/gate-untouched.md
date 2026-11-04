---
type: regex
target: { source: file, path: gate.js }
pattern: 'check\(shippedSms\(''1001'', ana\) === ''Order 1001 shipped to Ana Lima, Rua Augusta 10, 1100-053 Lisboa, Portugal\.'', '
match: "count:1"
---
