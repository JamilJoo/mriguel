---
type: regex
target: { source: file, path: src/catalog/collection-url.ts }
pattern: '-\+\/|-\{2,\}|--\+|\^-|filter\(Boolean\)|\[a-z0-9\]\+\/g|from [''"]\.{1,2}\/[^''"]*slug|import\s*\{[^}]*\bslugify\b[^}]*\}\s*from'
---
