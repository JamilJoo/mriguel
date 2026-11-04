---
name: mriguel-gain
description: Show what mriguel changes, measured with the plugin's own eval suite (with and without the plugin on the same tasks). Use when asked "mriguel gain", "what does mriguel save", "does mriguel work", or "show the scoreboard". One-shot display, changes nothing.
disable-model-invocation: true
---

# mriguel-gain

Show this scoreboard, then one line on how to refresh it. Do not invent numbers; the table is the last measured run.

| Suite (4 Nov 2026) | With plugin | Without | Where the plugin differs |
|---|---|---|---|
| 15 scaffolded repos the agent edits, 99 code graders, no judge, 3 runs | 42 of 45 (73 of 75 at 5 runs) | 42 of 45 | Fixes the shared function every time where the plain model guards the caller the ticket names (5/5 against 0/3); changes fewer copies of a helper copy-pasted into three files (3/5 against 3/3) |
| 12 temptation tickets answered in prose, Sonnet judge, 3 runs | 35 of 36 | 13 of 36 | Cache, dependency, retry policy, revenue bug, already-fixed bug: the small correct change instead of over-building or following the ticket |

Turns per real-file task: 4 with the plugin, 6 without (the repo map at session start replaces the exploration); cost per task about equal.

Refresh: in the plugin folder run `claude plugin eval . --eval-dir evals/edit --scaffold --allow-tools Bash Edit Write --ablation with-without --runs 5 --no-publish --report` and `claude plugin eval . --eval-dir evals/reply --ablation with-without --runs 5 --judge-model sonnet --no-publish --report`, then replace the table with the new per-suite numbers.
