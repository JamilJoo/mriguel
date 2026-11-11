---
type: regex
target: { source: file, path: src/orders/order.ts }
pattern: 'gift_?[wW]rap|gift_?[sS]ender'
match: not_contains
---
