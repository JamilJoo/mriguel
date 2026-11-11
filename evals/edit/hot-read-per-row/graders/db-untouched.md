---
type: regex
target: { source: file, path: src/db/db.ts }
pattern: 'stats\.queries\+\+;'
match: "count:3"
---
