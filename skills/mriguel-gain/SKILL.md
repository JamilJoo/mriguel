---
name: mriguel-gain
description: Show what mriguel changes, measured with the plugin's own eval suite (with and without the plugin on the same tasks). Use when asked "mriguel gain", "what does mriguel save", "does mriguel work", or "show the scoreboard". One-shot display, changes nothing.
disable-model-invocation: true
---

# mriguel-gain

Show this scoreboard, then one line on how to refresh it. Do not invent numbers; the table is the last measured run.

| Suite | With plugin | Without | Where the plugin differs |
|---|---|---|---|
| 19 scaffolded repos the agent edits, code graders, no judge, Opus 5.5, 11 Nov 2026 (five runs with; without: three runs on the 15 older repos, five on the 4 newer) | 92 of 95 | 50 of 65 | Fixes every reader of a wrong value where the plain model fixes the file the ticket names (5/5 against 0/5); leaves out fields a ticket asks for "for later" (5/5 against 0/5); the 15 older repos tie at full marks |
| Same 19 repos, Haiku 5.5, five runs | 84 of 95 | 75 of 95 | No unrequested config (5/5 against 1/5); the two newer scope rules do not hold on the small model |
| 12 temptation tickets answered in prose, Sonnet judge, 3 runs, 4 Nov 2026 on 1.2.0 | 35 of 36 | 13 of 36 | Cache, dependency, retry policy, revenue bug, already-fixed bug: the small correct change instead of over-building or following the ticket |

Turns per real-file task on Opus 5.5: 4.0 with the plugin, 6.1 without (the repo map at session start replaces the exploration); cost per task about equal.

Refresh: in the plugin folder run `claude plugin eval . --eval-dir evals/edit --scaffold --allow-tools Bash Edit Write --ablation with-without --runs 5 --no-publish --report` and `claude plugin eval . --eval-dir evals/reply --ablation with-without --runs 5 --judge-model sonnet --no-publish --report`, then replace the table with the new per-suite numbers.
