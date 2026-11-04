---
type: regex
target: { source: file, path: src/reports/daily.ts }
pattern: '// const old_cutoff = 1000 \* 60 \* 60 \* 24;|  var tmp2 = \[\];|function calc_Stuff\(list: Order\[\]\): number \{'
match: "count:3"
---
