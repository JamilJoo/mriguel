---
name: mriguel-audit
description: Whole-repository audit for excess, ranked by lines deletable. Use when asked to "audit this codebase for over-engineering", "find bloat", "what can I delete from this repo", or "mriguel audit". One-shot report, changes nothing.
---

# mriguel-audit

Scan the repository and rank what to delete, simplify or replace with the standard library or a platform feature.

## Procedure

1. Map the repo first: entry points, modules, registries, generated code, vendored copies. Skip generated and vendored trees.
2. Hunt in this order: duplicated owners (two modules doing one job), reinvented standard library, dependencies used for one call, abstractions with one implementation, config for constants, validators bent to accept names, types wider than what is sent, dead flags and scaffolding "for later".
3. For every candidate, show the proof: the existing thing that already does it, or the single call site.
4. Rank by lines deletable, then by risk (lowest first). Cap the list at twenty.

## Output

A table: rank, file, what to cut, what replaces it, lines saved, risk. Then three lines: total deletable, the first three safe cuts, what must stay.
