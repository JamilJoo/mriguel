---
name: mriguel-review
description: "Code review focused only on excess. Use when asked to \"review for over-engineering\", \"what can we delete\", \"is this over-built\", \"mriguel review\", or to check a diff against the mriguel rules. Finds reinvented standard library, needless dependencies, speculative abstractions, duplicated owners, bent validators and types wider than what the code sends. One line per finding. It does not hunt for bugs."
license: MIT
---

# mriguel-review

Review the given diff, PR or files for excess only. Correctness bugs go to a normal review.

## Procedure

1. Read the whole diff and every file it touches; trace callers before judging a change as unnecessary.
2. For each hunk ask, in order: does it need to exist; does the codebase already have it; does the standard library or the platform; is a new id, file, registry entry or checker change added for a behaviour that already has an owner; does a type list values the code never sends; is a dependency added for a few lines of work.
3. Report one line per finding: `file:line, cut <what>, use <what instead>`. Order by lines saved.
4. End with the three-line summary: lines that can go, the single biggest cut, what must stay (validation, data-loss handling, security, legal or customs obligations, explicit requests).

## Rules

- Evidence per finding: name the existing helper, library call or owner you would reuse. "Looks heavy" is not a finding.
- Never propose a rewrite; propose deletions and swaps.
- If nothing is excessive, say so in one line.
