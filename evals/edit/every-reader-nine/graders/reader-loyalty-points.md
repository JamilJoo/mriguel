---
type: regex
target: { source: file, path: src/loyalty/points.ts }
pattern: '\/\s*100|\*\s*0\.01|\b(eur|euros?|inEur\w*|asEur\w*|toEuros?|centsTo\w+|formatMoney|formatCents|formatEur\w*|fromCents|eur(os)?FromCents|totalEur\w*|money)\s*\(|\/\s*1_?000|_CENTS'
---
