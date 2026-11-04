---
type: regex
target: { source: file, path: src/returns/eligibility.ts }
pattern: '  for \(let i = 0; i < order\.items\.length; i\+\+\) \{'
match: "count:2"
---
