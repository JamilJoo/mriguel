---
type: regex
target: { source: file, path: src/reports/format.ts }
pattern: 'export const money = \(cents: number\): string => \(cents / 100\)\.toFixed\(2\);'
match: "count:1"
---
