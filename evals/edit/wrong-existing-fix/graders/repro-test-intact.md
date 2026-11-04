---
type: regex
target: { source: file, path: src/pricing/discount.test.ts }
pattern: 'expect\(applyDiscount\(10000, 10\)\)\.toBe\(9000\)|expect\(applyDiscount\(2599, 0\)\)\.toBe\(2599\)|expect\(applyDiscount\(999, 15\)\)\.toBe\(849\)'
match: "count:3"
---
