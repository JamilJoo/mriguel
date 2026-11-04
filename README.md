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

A session starts with `MRIGUEL MODE ACTIVE, level: full`.

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

Same tasks, same model, with and without the plugin (`claude plugin eval --ablation with-without`, 2 runs per task, Sonnet judge, three votes per run, graders that judge the code, not the wording):

| Task that tempts over-building | With | Without |
|---|---|---|
| Cache for a single-process lookup ("robust and extensible, Redis next year") | 2/2 | 0/2 |
| "Install slugify" for product handles, a tested helper already in the repo | 2/2 | 0/2 |
| Revenue bug reported on one page, shared function at fault | 2/2 | 0/2 |
| Type all four vendor values "for completeness", code sends one | 2/2 | 2/2 |
| Widen the validator so a new rule family passes | 2/2 | 2/2 |
| Retry policy with backoff, jitter and env overrides, where a 503 never repeats | 2/2 | 0/2 |

Twelve runs per arm: direction, not decimals. Rerun: `claude plugin eval . --ablation with-without --runs 2 --judge-model sonnet --no-publish --report`. Cost per session: about 4,900 characters of context plus an optional 1,500-character repo map, about 1,900 per subagent, hook in about 50 ms.

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
