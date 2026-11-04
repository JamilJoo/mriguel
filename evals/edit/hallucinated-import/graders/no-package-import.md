---
type: regex
target: { source: file, path: src/export/filename.ts }
pattern: '(from|import|require\()\s*[''"](?!\.{1,2}\/|node:)[^''"]+[''"]'
match: not_contains
---
