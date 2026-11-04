'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawn, spawnSync, execFileSync } = require('child_process');

const ROOT = path.join(__dirname, '..');
const NAME = require(path.join(ROOT, '.claude-plugin', 'plugin.json')).name;
const PREFIX = NAME.toUpperCase().replace(/[^A-Z0-9]+/g, '_') + '_';
const FIRST_RUNG = 'Does this need to exist at all';
const tmp = () => fs.mkdtempSync(path.join(os.tmpdir(), NAME + '-'));

function run(script, { input = {}, env = {}, home = tmp(), cwd = ROOT } = {}) {
  const r = spawnSync(process.execPath, [path.join(ROOT, 'hooks', script)], {
    input: JSON.stringify(input),
    encoding: 'utf8',
    cwd,
    env: { ...process.env, [PREFIX + 'HOME']: home, [PREFIX + 'DEFAULT_LEVEL']: '', [PREFIX + 'QUIET']: '', [PREFIX + 'MAP_CHARS']: '', [PREFIX + 'SUBAGENT_MATCH']: '', ...env },
  });
  assert.equal(r.status, 0, r.stderr);
  const out = r.stdout.trim();
  const json = out ? JSON.parse(out) : null;
  return { home, out, json, context: json ? json.hookSpecificOutput.additionalContext : '' };
}

test('session start injects the banner and the rules at the default level', () => {
  const r = run('activate.js');
  assert.equal(r.json.hookSpecificOutput.hookEventName, 'SessionStart');
  assert.match(r.context, new RegExp(`^${NAME.toUpperCase()} MODE ACTIVE, level: full`));
  assert.ok(r.context.includes(FIRST_RUNG));
  assert.ok(r.context.includes('## Active level\n\n- full'));
  assert.ok(!r.context.includes('## Levels'), 'the level menu is replaced by the active line');
});

test('session start is silent when the level is off', () => {
  const home = tmp();
  fs.writeFileSync(path.join(home, 'level'), 'off\n');
  assert.equal(run('activate.js', { home }).out, '');
});

test('default level and quiet knobs', () => {
  const r = run('activate.js', { env: { [PREFIX + 'DEFAULT_LEVEL']: 'ultra' } });
  assert.match(r.context, /level: ultra/);
  assert.ok(r.context.includes('- ultra'));
  const q = run('activate.js', { env: { [PREFIX + 'QUIET']: '1' } });
  assert.ok(!q.context.includes('MODE ACTIVE'));
  assert.ok(q.context.includes(FIRST_RUNG));
});

test('subagents get the compact rules without a repo map, and a matcher can scope them', () => {
  const r = run('subagent.js', { input: { agent_type: 'Explore' } });
  assert.equal(r.json.hookSpecificOutput.hookEventName, 'SubagentStart');
  assert.ok(r.context.includes('(subagent)') && /does this need to exist at all/i.test(r.context));
  assert.ok(r.context.includes('Active level: full'));
  assert.ok(!r.context.includes('Repo map'));
  assert.ok(r.context.length < 2600, `subagent context stays compact, got ${r.context.length} chars`);
  const env = { [PREFIX + 'SUBAGENT_MATCH']: '^Explore$' };
  assert.equal(run('subagent.js', { input: { agent_type: 'Plan' }, env }).out, '');
  assert.ok(/does this need to exist at all/i.test(run('subagent.js', { input: { agent_type: 'Explore' }, env }).context));
});

test('the level switch persists, reports, turns off and re-injects the rules when turned back on', () => {
  const home = tmp();
  const prompt = (p) => run('track.js', { input: { prompt: p }, home });
  assert.match(prompt(`/${NAME} ultra`).context, /LEVEL CHANGED: ultra/);
  assert.equal(fs.readFileSync(path.join(home, 'level'), 'utf8').trim(), 'ultra');
  assert.match(run('activate.js', { home }).context, /level: ultra/);
  assert.match(prompt(`/${NAME}`).context, /level: ultra/);
  assert.match(prompt('normal mode').context, /is off/);
  assert.equal(run('activate.js', { home }).out, '');
  const on = prompt(`/${NAME} full`);
  assert.match(on.context, /LEVEL CHANGED: full/);
  assert.ok(on.context.includes(FIRST_RUNG), 'rules come back with the mode');
  assert.match(prompt(`/some-marketplace:${NAME} lite`).context, /LEVEL CHANGED: lite/);
  assert.equal(prompt('please add a cache').out, '');
  assert.equal(prompt(`/${NAME}-review`).out, '', 'companion commands are not level switches');
});

test('a repo can pin the level with a dot file', () => {
  const repo = tmp();
  fs.writeFileSync(path.join(repo, '.' + NAME), 'lite\n');
  const home = tmp();
  assert.match(run('activate.js', { input: { cwd: repo }, home }).context, /level: lite/);
  const r = run('track.js', { input: { prompt: `/${NAME} ultra`, cwd: repo }, home });
  assert.match(r.context, /pinned to lite/);
  assert.ok(!fs.existsSync(path.join(home, 'level')), 'a pinned repo never writes the user level');
});

test('hooks finish even when the host never closes stdin', async () => {
  const child = spawn(process.execPath, [path.join(ROOT, 'hooks', 'activate.js')], { env: { ...process.env, [PREFIX + 'HOME']: tmp() } });
  let out = '';
  child.stdout.on('data', (c) => { out += c; });
  const code = await new Promise((resolve, reject) => {
    const timer = setTimeout(() => { child.kill(); reject(new Error('hook did not exit within 4 s')); }, 4000);
    child.on('exit', (c) => { clearTimeout(timer); resolve(c); });
  });
  assert.equal(code, 0);
  assert.ok(out.includes(FIRST_RUNG));
});

test('the repo map lists tracked files inside its budget and can be disabled', () => {
  const repo = tmp();
  fs.mkdirSync(path.join(repo, 'src', 'utils'), { recursive: true });
  fs.writeFileSync(path.join(repo, 'src', 'utils', 'text.ts'), '');
  fs.writeFileSync(path.join(repo, 'src', 'app.ts'), '');
  fs.writeFileSync(path.join(repo, 'README.md'), '');
  execFileSync('git', ['init', '-q'], { cwd: repo });
  execFileSync('git', ['add', '-A'], { cwd: repo });
  const r = run('activate.js', { input: { cwd: repo } });
  const map = r.context.slice(r.context.indexOf('Repo map'));
  assert.match(map, /Repo map \(3 files/);
  assert.ok(map.includes('src/utils/ (1): text.ts'));
  assert.ok(map.length <= 1500);
  const small = run('activate.js', { input: { cwd: repo }, env: { [PREFIX + 'MAP_CHARS']: '60' } });
  const smallMap = small.context.slice(small.context.indexOf('Repo map'));
  assert.ok(smallMap.length <= 60 + 40, 'budget respected, plus the one trailer line');
  assert.ok(!run('activate.js', { input: { cwd: repo }, env: { [PREFIX + 'MAP_CHARS']: '0' } }).context.includes('Repo map'));
});

test('a folder without git is mapped by walking it, skipping dependency trees', () => {
  const repo = tmp();
  fs.mkdirSync(path.join(repo, 'node_modules', 'x'), { recursive: true });
  fs.writeFileSync(path.join(repo, 'node_modules', 'x', 'index.js'), '');
  fs.writeFileSync(path.join(repo, 'main.py'), '');
  const r = run('activate.js', { input: { cwd: repo } });
  assert.match(r.context, /Repo map \(1 files/);
  assert.ok(!r.context.includes('node_modules'));
});
