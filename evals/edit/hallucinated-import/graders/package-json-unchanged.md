---
type: regex
target: { source: file, path: package.json }
pattern: '"dependencies": \{\}'
match: "count:1"
---
