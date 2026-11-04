'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const ROOT = path.join(__dirname, '..');
const manifest = JSON.parse(fs.readFileSync(path.join(ROOT, '.claude-plugin', 'plugin.json'), 'utf8'));
const NAME = manifest.name;
const FIRST_RUNG = 'Does this need to exist at all';
const { generated, textFiles, COMPANIONS } = require(path.join(ROOT, 'build.js'));

const node = (args, cwd = ROOT, env = {}) => spawnSync(process.execPath, args, { cwd, encoding: 'utf8', env: { ...process.env, ...env } });

test('generated host files are current', () => {
  const r = node(['build.js', 'check']);
  assert.equal(r.status, 0, r.stderr);
});

test('every host file carries the rules and every manifest parses', () => {
  const files = generated();
  for (const [rel, content] of Object.entries(files)) {
    assert.ok(fs.existsSync(path.join(ROOT, rel)), `${rel} missing`);
    if (rel.endsWith('.json')) JSON.parse(content);
    else if (!/-(review|audit|debt|gain|help)[./]/.test(rel)) assert.ok(content.includes(FIRST_RUNG), `${rel} lacks the ladder`);
  }
  const copilot = JSON.parse(files['hooks/copilot.json']);
  for (const hooks of Object.values(copilot.hooks)) for (const h of hooks) {
    const script = h.bash.match(/'hooks', '([a-z-]+\.js)'/);
    assert.ok(script && fs.existsSync(path.join(ROOT, 'hooks', script[1])), `copilot hook script missing in: ${h.bash}`);
    assert.ok(h.powershell.includes(script[1]));
  }
  assert.equal(Object.keys(files).filter((f) => f.startsWith('.openclaw/skills/')).length, 1 + COMPANIONS.length);
  assert.ok(!files['.agents/plugins/marketplace.json'] || JSON.parse(files['.agents/plugins/marketplace.json']).plugins[0].source.url);
  const gemini = JSON.parse(files['gemini-extension.json']);
  assert.ok(files[gemini.contextFileName].includes(FIRST_RUNG), 'the Gemini context file carries the rules');
  assert.equal(Object.keys(files).filter((f) => f.startsWith('commands/')).length, 1 + COMPANIONS.length);
  for (const [rel, content] of Object.entries(files)) if (rel.endsWith('.toml')) assert.match(content, /^description = ".*"\nprompt = '''\n/);
  assert.equal(JSON.parse(files['.grok-plugin/marketplace.json']).plugins[0].name, NAME);
  assert.equal(JSON.parse(files['.codex-plugin/plugin.json']).hooks, './hooks/claude.json');
});

test('hook commands are shell-agnostic and point at scripts that ship', () => {
  const cfg = JSON.parse(fs.readFileSync(path.join(ROOT, manifest.hooks), 'utf8'));
  const events = Object.keys(cfg.hooks);
  assert.deepEqual(events.sort(), ['SessionStart', 'SubagentStart', 'UserPromptSubmit']);
  for (const entries of Object.values(cfg.hooks)) for (const entry of entries) for (const hook of entry.hooks) {
    assert.equal(hook.type, 'command');
    assert.ok(hook.timeout <= 15);
    assert.ok(!/\[ -|&&|\|\||exec |bash /.test(hook.command), `POSIX-only syntax in: ${hook.command}`);
    const script = hook.command.match(/'hooks', '([a-z-]+\.js)'/);
    assert.ok(script, `no hooks script in: ${hook.command}`);
    assert.ok(fs.existsSync(path.join(ROOT, 'hooks', script[1])), `${script[1]} missing`);
  }
  assert.ok(!fs.existsSync(path.join(ROOT, 'hooks', 'hooks.json')), 'hooks/hooks.json would be auto-loaded by hosts that cannot run these hooks');
});

test('versions agree', () => {
  const pkg = JSON.parse(fs.readFileSync(path.join(ROOT, 'package.json'), 'utf8'));
  assert.equal(pkg.version, manifest.version);
  assert.equal(pkg.name, NAME);
  assert.equal(JSON.parse(fs.readFileSync(path.join(ROOT, '.claude-plugin', 'marketplace.json'), 'utf8')).plugins[0].name, NAME);
});

test('rename is one pass and reversible', () => {
  const copy = fs.mkdtempSync(path.join(os.tmpdir(), 'rename-'));
  fs.cpSync(ROOT, copy, { recursive: true, filter: (src) => !/node_modules|\.git$|results/.test(src) });
  const probe = 'zz-probe';
  let r = node(['build.js', 'rename', probe], copy);
  assert.equal(r.status, 0, r.stderr);
  assert.equal(JSON.parse(fs.readFileSync(path.join(copy, '.claude-plugin', 'plugin.json'), 'utf8')).name, probe);
  assert.ok(fs.existsSync(path.join(copy, 'skills', probe, 'SKILL.md')));
  assert.ok(fs.existsSync(path.join(copy, 'skills', `${probe}-review`, 'SKILL.md')));
  assert.ok(!fs.existsSync(path.join(copy, 'skills', NAME)));
  const leftovers = [];
  for (const file of textFiles.call(null, copy)) {
    const text = fs.readFileSync(file, 'utf8');
    if (text.includes(NAME) || text.includes(NAME.toUpperCase())) leftovers.push(path.relative(copy, file));
  }
  assert.deepEqual(leftovers, [], 'old name still present');
  assert.equal(node(['build.js', 'check'], copy).status, 0);
  const hook = spawnSync(process.execPath, [path.join(copy, 'hooks', 'activate.js')], { input: '{}', encoding: 'utf8', cwd: copy, env: { ...process.env, ZZ_PROBE_HOME: fs.mkdtempSync(path.join(os.tmpdir(), 'h-')) } });
  assert.match(JSON.parse(hook.stdout).hookSpecificOutput.additionalContext, /^ZZ-PROBE MODE ACTIVE/);
  r = node(['build.js', 'rename', NAME], copy);
  assert.equal(r.status, 0, r.stderr);
  for (const file of textFiles.call(null, copy)) assert.ok(!fs.readFileSync(file, 'utf8').includes(probe), `${file} still says ${probe}`);
  assert.equal(node(['build.js', 'check'], copy).status, 0);
});
