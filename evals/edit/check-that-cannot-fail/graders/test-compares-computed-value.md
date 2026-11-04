---
type: regex
target: { source: file, path: src/parse/quantity.test.ts }
pattern: 'expect\(\s*(parseQuantity\([^)]*\)|[A-Za-z_]\w*)\s*\)\s*\.(toBe|toEqual)\(\s*\d+\s*\)'
---
