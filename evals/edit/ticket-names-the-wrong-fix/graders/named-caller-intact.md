---
type: regex
target: { source: file, path: src/checkout/quote.ts }
pattern: 'const kg = chargeableKg\(parcels\);\n  return \{ kg, shippingCents: rateCents\(kg\) \};'
match: "count:1"
---
