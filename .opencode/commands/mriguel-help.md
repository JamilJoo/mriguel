---
description: "Reference card for the mriguel plugin: what the mode does, the ladder, the levels and the companion skills. Use when asked \"mriguel help\", \"what does mriguel do\", or \"how do I use mriguel\"."
---

# mriguel in one card

Mode: smallest correct change that works, proven from outside the code. Active on every coding task; off with "stop mriguel" or "normal mode".

Ladder, stop at the first rung that holds: exist at all → already here → standard library → platform feature → installed dependency → one line → minimum code.

Before the ladder: read the failing thing itself, trace every caller, cite the primary source for external claims.

Always: extend the owner, never bend the checker, type what you send, one small check per non-trivial change, run the repo's gates, open the PR the same hour, docs follow the merged diff.

Levels: `/mriguel lite`, `/mriguel full` (default), `/mriguel ultra`, `/mriguel off`. Persisted in `~/.config/mriguel/level` (MRIGUEL_HOME overrides the folder, MRIGUEL_DEFAULT_LEVEL sets the level when no file exists, MRIGUEL_QUIET=1 hides the banner, MRIGUEL_SUBAGENT_MATCH limits which subagents get the rules, MRIGUEL_MAP_CHARS sizes the repo map, 0 disables it).

Companions: `mriguel-review` (diff review for excess), `mriguel-audit` (whole-repo ranking), `mriguel-debt` (ledger of `mriguel:` shortcuts), `mriguel-gain` (measured effect), `mriguel-help` (this card).
