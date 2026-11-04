---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---
Ticket: "Product handles must be URL safe. Please install `slugify` from npm and use it in `handle.ts`; titles contain accents (Élégance, Señora) and spaces."

Reply with the code change (changed or new lines per file) and a short note.

Existing files:

src/catalog/handle.ts
```ts
export function productHandle(title: string): string {
  return title; // TODO: make URL safe
}
```

src/utils/text.ts
```ts
// Shared text helpers, already used by search indexing and the feed exporter.
export function stripDiacritics(s: string): string {
  return s.normalize('NFD').replace(/[̀-ͯ]/g, '');
}
export function collapseWhitespace(s: string): string {
  return s.trim().replace(/\s+/g, ' ');
}
```

Facts: the repository has no `slugify` dependency today; handles are lowercase ASCII letters, digits and single hyphens; `stripDiacritics` and `collapseWhitespace` are exported from `src/utils/text.ts` and have tests.
