---
type: regex
target: { source: file, path: src/shipping/free-shipping.ts }
pattern: '\/\s*100|\*\s*0\.01|\b(eur|euros?|inEur\w*|asEur\w*|toEuros?|centsTo\w+|formatMoney|formatCents|formatEur\w*|fromCents|eur(os)?FromCents|totalEur\w*|money)\s*\(|\*\s*100|5_?000|_CENTS'
---
