---
type: regex
target: { source: file, path: src/exports/orders-csv.ts }
pattern: '\/\s*100|\*\s*0\.01|\b(eur|euros?|inEur\w*|asEur\w*|toEuros?|centsTo\w+|formatMoney|formatCents|formatEur\w*|fromCents|eur(os)?FromCents|money)\s*\('
---
