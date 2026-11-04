---
type: regex
target: { source: file, path: gate.js }
pattern: 'check\(exportFileName\(''Shop 24/7'', new Date\(''2026-12-31T23:59:59Z''\)\) === ''orders-shop-24-7-2026-12-31\.csv'','
match: "count:1"
---
