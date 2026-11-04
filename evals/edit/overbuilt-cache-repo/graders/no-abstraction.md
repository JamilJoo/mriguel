---
type: regex
target: { source: file, path: src/products/product.service.ts }
pattern: 'interface \w*Cache|class \w*Cache|from [''"][^''"]*redis|require\([''"][^''"]*redis|new Redis\b|createClient\(|process\.env'
flags: i
match: not_contains
---
