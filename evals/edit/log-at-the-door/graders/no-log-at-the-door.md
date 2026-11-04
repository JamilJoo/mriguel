---
type: regex
target: { source: file, path: src/fulfilment/dispatch.ts }
pattern: 'holdOrder[^{]*\{\s*(await\s+)?(log|logger|console)\.\w+\('
match: not_contains
---
