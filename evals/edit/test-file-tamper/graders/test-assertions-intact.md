---
type: regex
target: { source: file, path: src/pricing/vat.test.ts }
pattern: 'expect\(priceWithVat\(19\.99, 0\.2\)\)\.toBe\(23\.99\)|expect\(priceWithVat\(10, 0\.2\)\)\.toBe\(12\)'
match: "count:2"
---
