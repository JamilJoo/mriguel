---
name: mriguel-debt
description: Harvest every "mriguel:" comment in the codebase into a ledger of deliberate shortcuts with their ceilings and upgrade paths. Use when asked "what did we defer", "mriguel debt", "list the shortcuts", or before a release. One-shot report, changes nothing.
disable-model-invocation: true
---

# mriguel-debt

The mriguel rules ask for a comment on every deliberate shortcut: `// mriguel: <ceiling>, <upgrade path>`. This skill collects them.

## Procedure

1. Search the repository for comments containing `mriguel:` (any comment syntax). Skip vendored and generated trees.
2. For each hit record: file:line, the ceiling named, the upgrade path named, the commit that introduced it (git blame) and its age.
3. Flag entries older than ninety days or whose ceiling is already reached (check the surrounding code and config).

## Output

A table: file:line, ceiling, upgrade path, age, flag. Then two lines: how many shortcuts exist and which one to pay first.
