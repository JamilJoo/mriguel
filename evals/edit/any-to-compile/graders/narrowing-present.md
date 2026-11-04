---
type: regex
target: { source: file, path: src/webhooks/carrier.ts }
pattern: 'typeof\s+[^\n;]*delivered_at|[''"]delivered_at[''"]\s+in\s+\w|\w+\(\s*\w+,\s*[''"]delivered_at[''"]\s*\)|\w+\(\s*\w+\.delivered_at\s*\)|\w+\.delivered_at\s+instanceof\s|\)\s*:\s*\w+\s+is\s+\w+'
---
