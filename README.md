# Mriguel

Mriguel makes AI coding agents ship the smallest change that actually works, prove it from outside the code, and stop there.

I built it because every agent I use loves to over-build. Ask for a cache and you get an adapter layer with a Redis stub. Report a bug on one page and the fix lands in that one caller while three others stay broken. Ask for a type and it grows four values "for completeness". The rules in here are the ones I keep repeating in reviews, written once and injected into every session and every subagent, so I don't have to repeat them anymore.

It's one skill file plus a few hooks. No dependencies, no services, nothing phoning home. MIT, do what you want with it.

## Contents

1. [What you get](#what-you-get)
2. [Quick start](#quick-start)
3. [Day to day](#day-to-day)
4. [Install on every host](#install-on-every-host)
5. [Measured, not claimed](#measured-not-claimed)
6. [Settings](#settings)
7. [How I use it](#how-i-use-it)
8. [Hacking on it](#hacking-on-it)
9. [FAQ](#faq)

## What you get

Most "write less code" rules stop at the diff. These start before it and end after it.

- Read first. Find the failing thing itself: the stored request and response, the log line, the exact error. A ticket names a symptom; the system holds the fact. Trace every caller before touching anything, and cite the vendor's own notice for any external claim.
- Then climb a ladder and stop at the first rung that holds: does it need to exist, is it already in the codebase, does the standard library do it, does the platform, does an installed dependency, can it be one line, only then the minimum code.
- Extend the owner. A behaviour that already has a module, a rule or a type gets extended there. No new id, file, registry entry or governance change for something that already has a home. Never bend a validator to accept your change. Type only what the code sends.
- Verification is part of the change, not a follow-up: one small runnable check per non-trivial change, the repo's own gates run before review, proof from outside the code, the pull request opened the same hour, docs that follow the merged diff.
- Shortcuts are marked, not hidden: `// mriguel: <ceiling>, <upgrade path>`. A companion harvests them into a ledger, so "later" stops meaning never.

The whole thing is one file, `skills/mriguel/SKILL.md`. Everything else in this repo is generated from it.

## Quick start

Claude Code (hooks, skills, level switch):

    claude plugin marketplace add JamilJoo/mriguel
    claude plugin install mriguel@mriguel

Open a new session. The first line of context reads `MRIGUEL MODE ACTIVE, level: full`. Type `/mriguel` to see the level, `/mriguel ultra` to change it.

Codex:

    codex plugin marketplace add JamilJoo/mriguel
    codex plugin add mriguel@mriguel

Grok app or grok.com: Settings, Customize, paste `RULES-short.md` into the custom instructions box. For a Grok Project paste `AGENTS.md`. Grok Build is in the table below.

Cursor, Windsurf, Kiro, Cline, Copilot, OpenCode, or anything that reads `AGENTS.md`: copy one generated file into your repo. No hooks, no install. Table below.

## Day to day

Levels. In Claude Code and Codex, `/mriguel lite|full|ultra|off` switches and persists across sessions. On a host without hooks, just say "lite", "full" or "ultra".

| Level | What changes |
|---|---|
| lite | The ladder as a reflex, fuller explanations allowed |
| full (default) | Ladder enforced, shortest diff, three-line explanations |
| ultra | One-liners where sane, no commentary |
| off | Nothing injected until you switch it back on |

"stop mriguel" or "normal mode" alone on a line also turns it off. A repo can pin the level for everyone working in it: put the level in a file named `.mriguel` at the root.

Companions, as skills and commands on every host that has commands:

| Command | Use |
|---|---|
| `/mriguel-review` | Review a diff for excess only: reinvented standard library, needless dependencies, speculative abstractions, duplicated owners, bent validators, types wider than what's sent. One line per finding. |
| `/mriguel-audit` | The whole repo ranked by lines deletable, capped at twenty, with proof per candidate. |
| `/mriguel-debt` | Ledger of every `mriguel:` shortcut comment: file, ceiling, upgrade path, age, flag. |
| `/mriguel-gain` | The measured effect, from the eval suite in this repo. |
| `/mriguel-help` | One card with the ladder, the levels and the companions. |

What a reply looks like at level full: the code, then `skipped: X, add when Y` in three lines at most. If the ticket asks for more than the facts support, you get the lean version and one sentence offering the rest. If you insist, you get the full version, no re-arguing.

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

Hooks need Node 18 or newer and nothing else. Every other adapter is plain text. Claude Code and Codex are the rows I run myself; the rest follow each host's documented format and I haven't exercised them on the host, so if one misbehaves, open an issue with what you saw.

## Measured, not claimed

Same tasks, same model, with and without the plugin: `claude plugin eval --ablation with-without`, 2 runs per task, Sonnet as judge with three votes per run, graders that judge what the code does rather than how the answer is worded.

| Task that tempts over-building | With | Without |
|---|---|---|
| Cache for a single-process lookup ("robust and extensible, Redis next year") | 2/2 | 0/2 |
| "Install slugify" for product handles, a tested helper already in the repo | 2/2 | 0/2 |
| Revenue bug reported on one page, shared function at fault | 2/2 | 0/2 |
| Type all four vendor values "for completeness", code sends one | 2/2 | 2/2 |
| Widen the validator so a new rule family passes | 2/2 | 2/2 |
| "Add a retry policy with backoff, jitter and env overrides" where a 503 never repeats | 2/2 | 0/2 |

On plain reuse and evidence tasks both arms already behave; the gain is on temptation. The suite also corrected two of my own rules, which is the point of having one: "never simplify away anything explicitly requested" made the agent obey a ticket's "for completeness" once, so the rule now separates a ticket asking from a person insisting; and "leave the calibration knob" produced backoff and jitter nobody needed, so it now asks for one constant, not a mechanism. Twelve runs per arm is a small sample, so read it as direction, not decimals. The suite is in `evals/`; rerun it yourself with `claude plugin eval . --ablation with-without --runs 2 --judge-model sonnet --no-publish --report` (one `--case` per invocation when filtering).

Cost per session: about 4,900 characters of context at session start, plus an optional 1,500-character repo map, and about 1,900 per subagent. The hook runs in about 50 ms.

## Settings

All optional, all environment variables:

| Variable | Effect | Default |
|---|---|---|
| `MRIGUEL_DEFAULT_LEVEL` | Level when nothing is persisted (`lite`, `full`, `ultra`, `off`) | `full` |
| `MRIGUEL_HOME` | Folder of the persisted level file | `~/.config/mriguel` (`%APPDATA%\mriguel` on Windows) |
| `MRIGUEL_QUIET` | `1` hides the banner line; the rules are still injected | unset |
| `MRIGUEL_SUBAGENT_MATCH` | Regular expression on the subagent type; only matching subagents get the rules | every subagent |
| `MRIGUEL_MAP_CHARS` | Size of the repo map printed at session start; `0` disables it | `1500` |

Level resolution, first match wins: `.mriguel` file in the repo root, then the persisted level, then `MRIGUEL_DEFAULT_LEVEL`, then `full`.

## How I use it

- A `.mriguel` file in shared repos, so every laptop behaves the same.
- Every deliberate shortcut gets its `// mriguel:` comment, and `/mriguel-debt` runs before a release.
- `/mriguel-review` on a pull request that feels heavy. It proposes deletions and swaps, never rewrites.
- The pull request goes up the same hour the branch exists. A branch without a PR gets no gates, no review and no deploy.
- Docs follow the merged diff, never the proposal.

## Hacking on it

- `skills/mriguel/SKILL.md` is the single source. Edit that, never the generated copies.
- `node build.js` regenerates every host file; `node build.js check` fails when one is stale (it's the first step of `npm test`).
- `node --test tests/*.test.js` (or `npm test`): hooks (activation, levels, pin, subagent matcher, repo map, stdin that never closes) and build (freshness, manifests, hook commands, rename round trip). Node 18 or newer, no dependencies.
- `node build.js rename <new-name>` renames the plugin everywhere in one pass, if you want to fork it under your own name.
- `node uninstall.js` removes the persisted level; then `claude plugin uninstall mriguel` or the equivalent in your host.
- Layout: `skills/` (source of truth), `hooks/` (plain Node), `build.js`, `tests/`, `evals/`, `RULES-short.md` (hand-written short form for custom-instruction boxes). Everything else is generated.

## FAQ

Does it make the agent cut corners? No. The ladder shortens the solution, never the reading, and it never removes validation at trust boundaries, data-loss handling, security, accessibility basics, legal obligations, or anything you insist on.

How do I turn it off for one task? `/mriguel off`, or say "normal mode". `/mriguel full` brings it back with the rules re-injected.

Does it work next to other plugins? Yes. It only adds context and a level file. It changes no settings and no files in your repos.

How do I update? `claude plugin update mriguel@mriguel` in Claude Code; other hosts pull this repo again or copy the regenerated file.

Where is my level stored? `~/.config/mriguel/level`, or wherever `MRIGUEL_HOME` points. Delete it or run `node uninstall.js` to reset.

Why not just a rules file? For hosts without hooks, that's exactly what the generated files are. With hooks you also get the level switch, the compact copy for every subagent, the repo map, and the rules coming back when you switch the mode on again.

Something's off on your host? Open an issue with the host and what you saw.

## License

MIT, Jamil Joo.
