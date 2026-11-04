# Mriguel

A coding mode for AI agents: the smallest correct change that works, proven from outside the code. Made by Jamil Joo for the Italist engineering team; MIT licensed, so use it anywhere.

Once installed, every coding session starts with the rules in context, every subagent gets a compact copy, and the agent answers with code first and at most three lines of explanation. Nothing else changes: validation, security, data-loss handling and legal or customs obligations are never cut.

## Contents

1. [What it does](#what-it-does)
2. [Quick start](#quick-start)
3. [Day to day](#day-to-day)
4. [Install on every host](#install-on-every-host)
5. [Measured](#measured)
6. [Settings](#settings)
7. [Team conventions](#team-conventions)
8. [Develop](#develop)
9. [FAQ](#faq)

## What it does

Most "write less code" rules stop at the diff. Mriguel starts before it and ends after it.

- Read first: find the failing thing itself (the stored request and response, the log line, the exact error), trace every caller, cite the vendor's own notice for any external claim. A ticket names a symptom; the system holds the fact.
- Climb a ladder and stop at the first rung that holds: does it need to exist, already in this codebase, standard library, platform feature, installed dependency, one line, only then the minimum code.
- Extend the owner: when a behaviour belongs to an existing module, rule or type, extend that one. No new id, file, registry entry or governance change for a behaviour that already has an owner. Never bend a validator to accept a change. Type only what the code sends.
- Verification is part of the change: one small runnable check per non-trivial change, the repo's own gates run before review, proof from outside the code, the pull request opened the same hour, docs that follow the merged diff.
- Deliberate shortcuts carry a comment, `// mriguel: <ceiling>, <upgrade path>`, and a companion harvests them into a ledger so "later" does not mean never.

The full text is one file: `skills/mriguel/SKILL.md`. Everything else in this repository is generated from it.

## Quick start

Claude Code (hooks, skills, level switch):

    claude plugin marketplace add JamilJoo/mriguel
    claude plugin install mriguel@mriguel

Open a new session. The first line of context reads `MRIGUEL MODE ACTIVE, level: full`. Type `/mriguel` to see the level, `/mriguel ultra` to change it.

Codex:

    codex plugin marketplace add JamilJoo/mriguel
    codex plugin add mriguel@mriguel

Grok app or grok.com: open Settings, Customize, and paste the contents of `RULES-short.md` into the custom instructions box. For a Grok Project, paste `AGENTS.md` instead. Grok Build users: see the table below.

Cursor, Windsurf, Kiro, Cline, Copilot, OpenCode, anything that reads `AGENTS.md`: copy one generated file into your repository (table below). No hooks, no install.

## Day to day

Levels, switched with `/mriguel lite|full|ultra|off` in Claude Code and Codex (persisted for later sessions), or by saying "lite", "full" or "ultra" to a host without hooks:

| Level | What changes |
|---|---|
| lite | The ladder as a reflex, fuller explanations allowed |
| full (default) | Ladder enforced, shortest diff, three-line explanations |
| ultra | One-liners where sane, no commentary |
| off | Nothing injected until switched back on |

"stop mriguel" or "normal mode" alone on a line also turns it off. A repository can pin the level for everyone working in it: put `full` (or any level) in a file named `.mriguel` at the repo root.

Companions, as skills and commands on every host that has commands:

| Command | Use |
|---|---|
| `/mriguel-review` | Review a diff for excess only: reinvented standard library, needless dependencies, speculative abstractions, duplicated owners, bent validators, types wider than what is sent. One line per finding. |
| `/mriguel-audit` | Whole repository ranked by lines deletable, capped at twenty, with proof per candidate. |
| `/mriguel-debt` | Ledger of every `mriguel:` shortcut comment: file, ceiling, upgrade path, age, flag. |
| `/mriguel-gain` | The measured effect, from the eval suite in this repository. |
| `/mriguel-help` | One card with the ladder, the levels and the companions. |

What a reply looks like at level full: the code, then `skipped: X, add when Y` in at most three lines. If the ticket asks for more than the facts support, the agent ships the lean version and offers the rest in one sentence; if you insist, it builds the full version without re-arguing.

## Install on every host

| Host | What it reads | How |
|---|---|---|
| Claude Code | plugin: hooks, skills | `claude plugin marketplace add JamilJoo/mriguel` then `claude plugin install mriguel@mriguel` |
| Codex | plugin: hooks, skills | `codex plugin marketplace add JamilJoo/mriguel` then `codex plugin add mriguel@mriguel` |
| Grok Build | skills | `grok plugin marketplace add JamilJoo/mriguel` then `grok plugin install mriguel --trust` |
| Grok app, grok.com | custom instructions | paste `RULES-short.md`; for a Project paste `AGENTS.md` |
| GitHub Copilot CLI | plugin: hooks, skills | install this repo as a plugin (`.github/plugin/plugin.json`); or copy `.github/copilot-instructions.md` for rules only |
| Gemini CLI | extension: context file, commands | `gemini extensions install https://github.com/JamilJoo/mriguel` |
| Cursor | always-on rule | copy `.cursor/rules/mriguel.mdc` into your repo |
| Windsurf | always-on rule | copy `.windsurf/rules/mriguel.md` into your repo |
| Kiro | steering | copy `.kiro/steering/mriguel.md` into your repo |
| Cline | rules | copy `.clinerules/mriguel.md` into your repo |
| OpenCode | AGENTS.md, commands | copy `AGENTS.md` and `.opencode/commands/` into your repo |
| Qoder | plugin: skills, rules | `.qoder-plugin/plugin.json`; or copy `.qoder/rules/mriguel.md` |
| Kimi Code | plugin: skills, system prompt | `.kimi-plugin/plugin.json` |
| Devin | plugin: skills | `.devin-plugin/plugin.json` |
| OpenClaw | skills | `.openclaw/skills/` |
| Antigravity and other `.agents` readers | rules | copy `.agents/rules/mriguel.md` |
| Anything that reads AGENTS.md | instructions file | copy `AGENTS.md` |

Hooks need Node 18 or newer and nothing else; every other adapter is plain text. The Claude Code and Codex rows are the ones tested on a real host; the others follow each host's documented format and are untested here, so tell Jamil if one misbehaves.

## Measured

Same tasks, same model, with and without the plugin (`claude plugin eval --ablation with-without`, 3 and 4 Nov 2026, 2 runs per task, Sonnet as judge with three votes per run, graders that judge what the code does rather than its wording):

| Task that tempts over-building | With | Without |
|---|---|---|
| Cache for a single-process lookup ("robust and extensible, Redis next year") | 2/2 | 0/2 |
| "Install slugify" for product handles, a tested helper already in the repo | 2/2 | 0/2 |
| Revenue bug reported on one page, shared function at fault | 2/2 | 0/2 |
| Type all four vendor values "for completeness", code sends one | 2/2 | 2/2 |
| Widen the validator so a new rule family passes | 2/2 | 2/2 |
| "Add a retry policy with backoff, jitter and env overrides" where a 503 never repeats | 2/2 | 0/2 |

On plain reuse and evidence tasks both arms already behave; the gain is on temptation. Two rules were corrected by the suite itself and the cases re-run: "never simplify away anything explicitly requested" made the plugin obey a ticket's "for completeness" once, so it now distinguishes a ticket asking from a user insisting; and "leave the calibration knob" produced backoff and jitter nobody needed, so it now asks for one constant, not a mechanism. Twelve runs per arm is a small sample; treat the table as direction, not precision. The suite is in `evals/`; rerun it with `claude plugin eval . --ablation with-without --runs 2 --judge-model sonnet --no-publish --report` (one `--case` per invocation when filtering).

Cost per session: about 4,900 characters of context at session start (plus a 1,500-character repo map, optional), about 1,900 per subagent. The hook runs in about 50 ms.

## Settings

All optional, all environment variables:

| Variable | Effect | Default |
|---|---|---|
| `MRIGUEL_DEFAULT_LEVEL` | Level when nothing is persisted (`lite`, `full`, `ultra`, `off`) | `full` |
| `MRIGUEL_HOME` | Folder of the persisted level file | `~/.config/mriguel` (`%APPDATA%\mriguel` on Windows) |
| `MRIGUEL_QUIET` | `1` hides the banner line; the rules are still injected | unset |
| `MRIGUEL_SUBAGENT_MATCH` | Regular expression on the subagent type; only matching subagents get the rules | every subagent |
| `MRIGUEL_MAP_CHARS` | Size of the repo map printed at session start; `0` disables it | `1500` |

Level resolution, first match wins: `.mriguel` file in the repository root, then the persisted level, then `MRIGUEL_DEFAULT_LEVEL`, then `full`.

## Team conventions

- Pin the level in shared repositories with a `.mriguel` file so every laptop behaves the same.
- Mark every deliberate shortcut with `// mriguel: <ceiling>, <upgrade path>` and run `/mriguel-debt` before a release.
- Run `/mriguel-review` on a pull request when it feels heavy; it reports deletions and swaps, never rewrites.
- Open the pull request the same hour the branch exists. A branch without a PR gets no gates, no review and no deploy.
- Docs follow the merged diff, never the proposal.

## Develop

- `skills/mriguel/SKILL.md` is the single source. Edit it, never the generated copies.
- `node build.js` regenerates every host file; `node build.js check` fails when one is stale (first step of `npm test`).
- `node --test tests/*.test.js` (or `npm test`): hooks (activation, levels, pin, subagent matcher, repo map, stdin that never closes) and build (freshness, manifests, hook commands, rename round trip). Node 18 or newer, no dependencies.
- `node build.js rename <new-name>` renames the plugin everywhere in one pass.
- `node uninstall.js` removes the persisted level; then `claude plugin uninstall mriguel` (or the equivalent in your host).
- Files: `skills/` (source of truth), `hooks/` (plain Node), `build.js`, `tests/`, `evals/`, `RULES-short.md` (hand-written short form for custom-instruction boxes); everything else is generated.

## FAQ

Does it make the agent cut corners? No. The ladder shortens the solution, never the reading, and it never removes validation at trust boundaries, data-loss handling, security, accessibility basics, legal or customs obligations, or anything you insist on.

How do I turn it off for one task? `/mriguel off`, or say "normal mode"; `/mriguel full` brings it back with the rules re-injected.

Does it work next to other plugins? Yes. It only adds context and a level file; it changes no settings and no files in your repositories.

How do I update? `claude plugin update mriguel@mriguel` in Claude Code; other hosts pull this repository again or copy the regenerated file.

Where is my level stored? In `~/.config/mriguel/level` (or `MRIGUEL_HOME`). Delete it or run `node uninstall.js` to reset.

Why not just a rules file? For hosts without hooks, that is exactly what the generated files are. With hooks you also get the level switch, the per-subagent copy, the repo map and the re-injection when you switch the mode back on.

Something is off on my host? Tell Jamil which host and what you saw; the adapters outside Claude Code and Codex are generated from documented formats but untested here.

## License

MIT, Jamil Joo.
