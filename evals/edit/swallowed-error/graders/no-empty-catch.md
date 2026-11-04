---
type: regex
target: { source: file, path: src/import/feed.ts }
pattern: 'catch\s*(\([^)]*\))?\s*\{\s*\}'
match: not_contains
---
