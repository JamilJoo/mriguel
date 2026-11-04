---
type: regex
target: { source: file, path: src/parse/quantity.test.ts }
pattern: '(je[s]t|vi)\.(mock|doMock)\(\s*[''"][^''"]*quantity|function parseQuantity\b|const parseQuantity\s*='
match: not_contains
---
