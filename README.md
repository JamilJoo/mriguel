# Mriguel

Makes AI coding agents ship the smallest change that works, prove it, and stop. One skill file plus a few hooks, no dependencies, MIT.

## The rules, in short

- Read first: the stored error, the log line, every caller. Then decide.
- Climb the ladder and stop at the first rung that holds: needed at all, already in the codebase, standard library, platform feature, installed dependency, one line, only then the minimum code.
- Extend the owner, never bend the checker, type only what the code sends.
- One runnable check per change, the repo's own gates before review, proof from outside the code, the PR up the same hour, docs after the merge.
- Shortcuts marked, not hidden: `// mriguel: <ceiling>, <upgrade path>`.

Full text: `skills/mriguel/SKILL.md`. Everything else in the repo is generated from it.

## Install

Claude Code:

    claude plugin marketplace add JamilJoo/mriguel
    claude plugin install mriguel@mriguel

Codex:

    codex plugin marketplace add JamilJoo/mriguel
    codex plugin add mriguel@mriguel

Grok app: Settings, Customize, paste `RULES-short.md`. Everything else: copy one file.

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

Hooks need Node 18 or newer. I run Claude Code and Codex; the other rows follow each host's documented format, so open an issue if one misbehaves.

## Use

A session starts with `MRIGUEL MODE ACTIVE, level: full`. The companions below run only when you call them.

| Level | What changes |
|---|---|
| lite | The ladder as a reflex, fuller explanations allowed |
| full (default) | Ladder enforced, shortest diff, three-line explanations |
| ultra | One-liners where sane, no commentary |
| off | Nothing injected until you switch it back on |

`/mriguel lite|full|ultra|off` persists across sessions; `/mriguel` alone reports; "stop mriguel" or "normal mode" turns it off. A `.mriguel` file in a repo root pins the level for everyone there.

| Command | Use |
|---|---|
| `/mriguel-review` | A diff reviewed for excess only, one line per finding |
| `/mriguel-audit` | The whole repo ranked by lines deletable, capped at twenty |
| `/mriguel-debt` | Ledger of every `mriguel:` shortcut: file, ceiling, upgrade path, age |
| `/mriguel-gain` | The measured effect, from the eval suite in this repo |
| `/mriguel-help` | One card: ladder, levels, companions |

A reply at level full: the code, then `skipped: X, add when Y`, three lines at most. Validation, security, data-loss handling and legal obligations are never cut; if you insist on the full version, you get it.

## Measured

Real-file tasks, graded by code, with and without the plugin on the same model (11 Nov 2026, version 1.3.0):

| Model | With | Without | Turns per task |
|---|---|---|---|
| Opus 5.5, 19 scaffolded repos, five runs with the plugin; without: three runs on the 15 older repos, five on the 4 newer | 92/95 | 50/65 | 4.0 against 6.1 |
| Haiku 5.5, same 19 repos, five runs | 84/95 | 75/95 | 8.4 against 9.3 |
| Fable 5.2, six of the repos, two runs | 12/12 | 10/12 | 3.3 against 4.8 |

Where the plugin changes the outcome on a strong model: when a wrong value is read in several files and the ticket names one, it fixes every reader (5/5 against 0/5 with five readers; 2/5 against 0/5 with nine); when a ticket asks for fields "for later", it leaves them out (5/5 against 0/5). On the 15 older repos (over-building, bent checkers, swallowed errors, tampered tests) Opus 5.5 scores full marks with or without the plugin; there the plugin saves turns, because the repo map at session start replaces the exploration. Cost per task is about equal. On Haiku 5.5 the classic cases still move (no unrequested config: 5/5 against 1/5) and the two newer scope rules do not hold (0/5).

Prose tickets (12 temptation tickets, Sonnet judge, three runs, measured 4 Nov 2026 on 1.2.0 and not re-run): 35/36 with, 13/36 without.

The 4 newer repos were built from misses seen in real work the same week as the rules that address them, so they favour the plugin by construction. The suite and the release rule are in `evals/README.md`; five runs per arm is the minimum that separates an effect from run-to-run swing.

## Settings

| Variable | Effect | Default |
|---|---|---|
| `MRIGUEL_DEFAULT_LEVEL` | Level when nothing is persisted | `full` |
| `MRIGUEL_HOME` | Folder of the persisted level file | `~/.config/mriguel` (`%APPDATA%\mriguel` on Windows) |
| `MRIGUEL_QUIET` | `1` hides the banner line, rules still injected | unset |
| `MRIGUEL_SUBAGENT_MATCH` | Regex on the subagent type; only matches get the rules | every subagent |
| `MRIGUEL_MAP_CHARS` | Size of the repo map at session start, `0` disables it | `1500` |

Resolution, first match wins: `.mriguel` in the repo root, the persisted level, `MRIGUEL_DEFAULT_LEVEL`, `full`.

## Hacking on it

- Edit `skills/mriguel/SKILL.md`, never the generated copies; `node build.js` regenerates, `node build.js check` fails on drift.
- `npm test`: drift check plus hook and build tests. Node 18 or newer, no dependencies.
- `node build.js rename <new-name>` renames everything in one pass.
- `node uninstall.js` removes the persisted level, then `claude plugin uninstall mriguel`. Update with `claude plugin update mriguel@mriguel`.

## License

MIT, Jamil Joo.
