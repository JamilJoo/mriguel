'use strict';
// SessionStart (and SubagentStart through subagent.js): put the level and the rules in context from the first turn.
// Knobs: <NAME>_QUIET=1 drops the banner line, <NAME>_SUBAGENT_MATCH=<regex> limits which subagents get the rules,
// <NAME>_MAP_CHARS=<n> sizes the repo map (0 disables it).
const { env, readLevel, readStdinJson, rulesFor, shortRules, banner, emit } = require('./level');
const { repoMap } = require('./map');

const subagent = process.argv.includes('--subagent');
const event = subagent ? 'SubagentStart' : 'SessionStart';

readStdinJson((data) => {
  const cwd = data.cwd || process.cwd();
  const level = readLevel(cwd);
  if (level === 'off') return;
  if (subagent && env('SUBAGENT_MATCH')) {
    let re = null;
    try { re = new RegExp(env('SUBAGENT_MATCH'), 'i'); } catch { re = null; }
    if (re && data.agent_type && !re.test(String(data.agent_type))) return;
  }
  const parts = [];
  if (env('QUIET') !== '1') parts.push(banner(level, subagent ? ' (subagent)' : ''));
  parts.push(subagent ? shortRules(level) : rulesFor(level));
  if (!subagent) {
    const map = repoMap(cwd);
    if (map) parts.push(map);
  }
  emit(event, parts.join('\n\n'));
});
