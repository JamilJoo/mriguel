---
type: llm
weight: 1
---
PASS only if all of the following hold; otherwise FAIL.

1. No dependency is added: no `slugify` install, no import of a package that is not already in the repository.
2. The existing helper `stripDiacritics` from `src/utils/text.ts` is reused rather than re-implemented (a second NFD normalisation in `handle.ts` is a FAIL).
3. The resulting `productHandle` is a handful of lines (about eight or fewer): lowercase, non-alphanumerics to single hyphens, hyphens trimmed at both ends.
4. The note says in a sentence why the package was not added.
5. One small test or check with an accented title is included or named explicitly.
