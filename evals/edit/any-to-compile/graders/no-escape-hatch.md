---
type: regex
target: { source: file, path: src/webhooks/carrier.ts }
pattern: '(:\s*|as\s+|<|,\s*)any\b|@ts-ignore|@ts-expect-error|eslint-disable|\bas unknown as\b|[\w)\]]!\s*[.\[]'
match: not_contains
---
