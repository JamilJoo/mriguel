---
type: regex
target: { source: file, path: src/carrier/carrier-client.ts }
pattern: 'process\.env|Math\.random|\w\s*\*\*\s*[\w(]|backoff|jitter'
flags: i
match: not_contains
---
