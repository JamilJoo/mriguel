---
type: regex
target: { source: file, path: src/import/feed.ts }
pattern: 'catch\s*(\([^)]*\))?\s*\{\s*(console\.\w+|log(ger)?\.\w+)\([^;]*\);?\s*\}'
match: not_contains
---
