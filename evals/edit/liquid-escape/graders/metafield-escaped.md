---
type: regex
target: { source: file, path: sections/care-materials.liquid }
pattern: 'care_note[^}]*\|\s*(escape|escape_once|metafield_tag)\b|assign\s+(\w+)\s*=\s*product\.metafields\.custom\.care_note[\s\S]*?\{\{-?\s*\2\s*\|\s*(escape|escape_once|metafield_tag)\b'
---
