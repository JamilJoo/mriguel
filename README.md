# Mriguel

Mriguel makes AI coding agents ship the smallest change that actually works, prove it from outside the code, and stop there.

I built it because getting code out of an agent is easy; getting it to stop is the hard part. Every extra line is something a person has to review, maintain and debug, and agents have no feel for that cost. Mriguel gives them one: understand the problem fully, build the least that solves it, prove it works, and say what was left out and when it would be worth adding.

One skill file plus a few hooks. No dependencies, nothing phoning home. MIT.

## What you get

- Read first: the stored request and response, the log line, the exact error. A ticket names a symptom; the system holds the fact. Trace every caller before touching anything.
- A ladder, stop at the first rung that holds: does it need to exist, already in the codebase, standard library, platform feature, installed dependency, one line, only then the minimum code.
- Extend the owner: no new id, file, registry entry or governance change for a behaviour that already has a home. Never bend a validator to accept your change. Type only what the code sends.
- Verification inside the change: one small runnable check, the repo's own gates before review, proof from outside the code, the PR opened the same hour, docs after the merge.
- Shortcuts marked, not hidden: `// mriguel: <ceiling>, <upgrade path>`, harvested later into a ledger.

Everything lives in `skills/mriguel/SKILL.md`; the rest of the repo is generated from it.

## Quick start

Claude Code:

    claude plugin marketplace add JamilJoo/mriguel
    claude plugin install mriguel@mriguel

Codex:

    codex plugin marketplace add JamilJoo/mriguel
    codex plugin add mriguel@mriguel

Grok app: Settings, Customize, paste `RULES-short.md` (a Project takes `AGENTS.md`). Every other host: copy one generated file into your repo, table below.

A new session starts with `MRIGUEL MODE ACTIVE, level: full`. `/mriguel` shows the level, `/mriguel ultra` changes it.

## Day to day

| Level | What changes |
|---|---|
| lite | The ladder as a reflex, fuller explanations allowed |
| full (default) | Ladder enforced, shortest diff, three-line explanations |
| ultra | One-liners where sane, no commentary |
| off | Nothing injected until you switch it back on |

`/mriguel lite|full|ultra|off` persists across sessions (hosts without hooks: just say the level). "stop mriguel" or "normal mode" turns it off. A `.mriguel` file in a repo root pins the level for everyone working there.

| Command | Use |
|---|---|
| `/mriguel-review` | A diff reviewed for excess only, one line per finding |
| `/mriguel-audit` | The whole repo ranked by lines deletable, capped at twenty |
| `/mriguel-debt` | Ledger of every `mriguel:` shortcut: file, ceiling, upgrade path, age |
| `/mriguel-gain` | The measured effect, from the eval suite in this repo |
| `/mriguel-help` | One card: ladder, levels, companions |

A reply at level full is the code, then `skipped: X, add when Y` in three lines at most. A ticket asking for more than the facts support gets the lean version plus one sentence offering the rest; if you insist, you get the full version.

## Install on every host

| Host | What it reads | How |
|---|---|---|
| Claude Code | plugin: hooks, skills | `claude plugin marketplace add JamilJoo/mriguel` then `claude plugin install mriguel@mriguel` |
| Codex | plugin: hooks, skills | `codex plugin marketplace add JamilJoo/mriguel` then `codex plugin add mriguel@mriguel` |
| Grok Build | skills | `grok plugin marketplace add JamilJoo/mriguel` then `grok plugin install mriguel --trust` |
| Grok app, grok.com | custom instructions | paste `RULES-short.md`; for a Project paste `AGENTS.md` |
| GitHub Copilot CLI | plugin: hooks, skills | install this repo as a plugin (`.github/plugin/plugin.json`), or copy `.github/copilot-instructions.md` for rules only |
| Gemini CLI | extension: context file, commands | `gemini extensions install https://github.com/JamilJoo/mriguel` |
| Cursor | always-on rule | copy `.cursor/rules/mriguel.mdc` |
| Windsurf | always-on rule | copy `.windsurf/rules/mriguel.md` |
| Kiro | steering | copy `.kiro/steering/mriguel.md` |
| Cline | rules | copy `.clinerules/mriguel.md` |
| OpenCode | AGENTS.md, commands | copy `AGENTS.md` and `.opencode/commands/` |
| Qoder | plugin: skills, rules | `.qoder-plugin/plugin.json`, or copy `.qoder/rules/mriguel.md` |
| Kimi Code | plugin: skills, system prompt | `.kimi-plugin/plugin.json` |
| Devin | plugin: skills | `.devin-plugin/plugin.json` |
| OpenClaw | skills | `.openclaw/skills/` |
| Antigravity and other `.agents` readers | rules | copy `.agents/rules/mriguel.md` |
| Anything that reads AGENTS.md | instructions file | copy `AGENTS.md` |

Hooks need Node 18 or newer, nothing else. I run Claude Code and Codex myself; the other rows follow each host's documented format, so if one misbehaves, open an issue with what you saw.

## Measured, not claimed

Same tasks, same model, with and without the plugin (`claude plugin eval --ablation with-without`, 2 runs per task, Sonnet judge with three votes per run, graders that judge the code, not the wording):

| Task that tempts over-building | With | Without |
|---|---|---|
| Cache for a single-process lookup ("robust and extensible, Redis next year") | 2/2 | 0/2 |
| "Install slugify" for product handles, a tested helper already in the repo | 2/2 | 0/2 |
| Revenue bug reported on one page, shared function at fault | 2/2 | 0/2 |
| Type all four vendor values "for completeness", code sends one | 2/2 | 2/2 |
| Widen the validator so a new rule family passes | 2/2 | 2/2 |
| Retry policy with backoff, jitter and env overrides, where a 503 never repeats | 2/2 | 0/2 |

The gain is on temptation; on plain reuse tasks both arms already behave. The suite corrected two of my own rules along the way (a ticket asking is not a person insisting; a calibration knob is one constant, not a mechanism). Twelve runs per arm is direction, not decimals. Rerun it: `claude plugin eval . --ablation with-without --runs 2 --judge-model sonnet --no-publish --report`, one `--case` per invocation when filtering.

Cost: about 4,900 characters of context per session plus an optional 1,500-character repo map, about 1,900 per subagent, hook in about 50 ms.

## Settings

| Variable | Effect | Default |
|---|---|---|
| `MRIGUEL_DEFAULT_LEVEL` | Level when nothing is persisted | `full` |
| `MRIGUEL_HOME` | Folder of the persisted level file | `~/.config/mriguel` (`%APPDATA%\mriguel` on Windows) |
| `MRIGUEL_QUIET` | `1` hides the banner line, rules still injected | unset |
| `MRIGUEL_SUBAGENT_MATCH` | Regex on the subagent type; only matches get the rules | every subagent |
| `MRIGUEL_MAP_CHARS` | Size of the repo map at session start, `0` disables it | `1500` |

Resolution, first match wins: `.mriguel` in the repo root, the persisted level, `MRIGUEL_DEFAULT_LEVEL`, `full`.

## How I use it

- `.mriguel` in shared repos, so every laptop behaves the same.
- `/mriguel-debt` before a release; every shortcut already carries its comment.
- `/mriguel-review` on a PR that feels heavy; it proposes deletions and swaps, never rewrites.
- The PR goes up the same hour the branch exists. Docs follow the merged diff.

## Hacking on it

- Edit `skills/mriguel/SKILL.md`, never the generated copies.
- `node build.js` regenerates every host file; `node build.js check` fails on drift.
- `npm test`: drift check plus hook and build tests (`node --test tests/*.test.js`). Node 18 or newer, no dependencies.
- `node build.js rename <new-name>` renames everything in one pass, for a fork under your own name.
- `node uninstall.js` removes the persisted level, then `claude plugin uninstall mriguel` or your host's equivalent.

## FAQ

Does it cut corners? No. It shortens the solution, never the reading, and never removes validation at trust boundaries, data-loss handling, security, accessibility basics, legal obligations, or anything you insist on.

Off for one task? `/mriguel off` or "normal mode"; `/mriguel full` brings the rules back.

Next to other plugins? Fine. It adds context and a level file, changes no settings and no files in your repos.

Update? `claude plugin update mriguel@mriguel`; other hosts pull the repo again.

Why not just a rules file? For hosts without hooks, that's what the generated files are. Hooks add the level switch, the compact copy per subagent, the repo map, and the rules coming back when you switch on again.

## License

MIT, Jamil Joo.
