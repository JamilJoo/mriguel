#!/usr/bin/env node
'use strict';
// One source, every host. The rules live in skills/<name>/SKILL.md and the identity in .claude-plugin/plugin.json;
// everything another host needs is generated from those two, so copies cannot drift.
//   node build.js                 write every generated adapter
//   node build.js check           exit 1 when a generated file on disk differs from what build would write
//   node build.js rename <name>   rename the plugin everywhere (folders, identifiers, text), then build
const fs = require('fs');
const path = require('path');

const ROOT = __dirname;
const COMPANIONS = ['review', 'audit', 'debt', 'gain', 'help'];
const SKIP_DIRS = new Set(['node_modules', '.git', 'results', 'evals-round1']);
const BINARY = /\.(zip|png|jpg|jpeg|gif|ico|pdf|woff2?)$/i;

const read = (rel) => fs.readFileSync(path.join(ROOT, rel), 'utf8');
const json = (obj) => JSON.stringify(obj, null, 2) + '\n';
const manifest = () => JSON.parse(read('.claude-plugin/plugin.json'));
const frontmatter = (lines) => `---\n${lines.join('\n')}\n---\n\n`;

function skill(name) {
  const text = read(`skills/${name}/SKILL.md`);
  const m = text.match(/^---\n([\s\S]*?)\n---\n*/);
  const front = m ? m[1] : '';
  const description = (front.match(/^description:\s*(.*)$/m) || [, ''])[1].trim();
  return { description, body: text.slice(m ? m[0].length : 0).trim() + '\n' };
}

function generated() {
  const { name, version, description, author, keywords = [], repository } = manifest();
  const rules = skill(name);
  const files = {};
  const companions = COMPANIONS.map((c) => `${name}-${c}`);
  files['AGENTS.md'] = rules.body;
  files[`.cursor/rules/${name}.mdc`] = frontmatter([`description: ${JSON.stringify(rules.description)}`, 'globs:', 'alwaysApply: true']) + rules.body;
  files[`.windsurf/rules/${name}.md`] = frontmatter(['trigger: always_on']) + rules.body;
  files[`.kiro/steering/${name}.md`] = frontmatter(['inclusion: always']) + rules.body;
  files[`.clinerules/${name}.md`] = rules.body;
  files['.github/copilot-instructions.md'] = rules.body;
  files['plugin.json'] = json({ name, version, description });
  files['gemini-extension.json'] = json({ name, version, description, contextFileName: 'AGENTS.md' });
  files['.codex-plugin/plugin.json'] = json({ name, version, description, author, license: 'MIT', skills: './skills/', hooks: './hooks/claude.json' });
  files['.grok-plugin/marketplace.json'] = json({
    name, description, owner: author,
    plugins: [{ name, description, category: 'productivity', source: { type: 'local', path: './' } }],
  });
  files['.qoder-plugin/plugin.json'] = json({ name, version, description, author, license: 'MIT', skills: './skills/', rules: './.qoder/rules/' });
  files[`.qoder/rules/${name}.md`] = rules.body;
  files['.kimi-plugin/plugin.json'] = json({ name, description, author, license: 'MIT', interface: { displayName: name, shortDescription: description }, skills: './skills/', systemPromptPath: './AGENTS.md' });
  files['.devin-plugin/plugin.json'] = json({ name, version, description, author, license: 'MIT', keywords });
  files[`.agents/rules/${name}.md`] = rules.body;
  // GitHub Copilot CLI plugin: manifest, catalogue and hooks with a bash and a PowerShell form; PLUGIN_ROOT is the host's variable.
  const copilotCmd = (script) => `node -e "require(require('path').join(process.env.PLUGIN_ROOT, 'hooks', '${script}'))"`;
  const copilotHook = (script) => ({ type: 'command', bash: `${copilotCmd(script)} || exit 0`, powershell: `if (Get-Command node -ErrorAction SilentlyContinue) { ${copilotCmd(script)} }`, timeoutSec: 15 });
  files['hooks/copilot.json'] = json({ version: 1, hooks: { sessionStart: [copilotHook('activate.js')], userPromptSubmitted: [copilotHook('track.js')] } });
  files['.github/plugin/plugin.json'] = json({ name, description, version, author, license: 'MIT', keywords, skills: 'skills/', hooks: 'hooks/copilot.json' });
  files['.github/plugin/marketplace.json'] = json({ name, description, owner: author, plugins: [{ name, description, source: './', category: 'productivity', skills: 'skills/', hooks: 'hooks/copilot.json' }] });
  // Codex catalogue entry points at a public repository; generated once plugin.json carries one.
  if (repository) {
    files['.agents/plugins/marketplace.json'] = json({ name, interface: { displayName: name }, plugins: [{ name, source: { source: 'url', url: repository, ref: 'main' }, policy: { installation: 'AVAILABLE', authentication: 'ON_INSTALL' }, category: 'Productivity' }] });
  }
  for (const s of [name, ...companions]) {
    const sk = skill(s);
    files[`.openclaw/skills/${s}/SKILL.md`] = frontmatter([`name: ${s}`, `description: ${JSON.stringify(sk.description)}`, 'license: MIT']) + sk.body;
  }
  const levelPrompt = `Level "{{args}}" requested (full when empty) for this conversation: confirm it in one line, then follow these rules on every code change.\n\n${rules.body}`;
  const commands = [[name, 'Switch the level (lite, full, ultra, off) and apply the rules', levelPrompt]];
  for (const c of companions) {
    const s = skill(c);
    commands.push([c, s.description, s.body]);
  }
  for (const [cmd, desc, prompt] of commands) {
    if (prompt.includes("'''")) throw new Error(`${cmd}: three single quotes would end the TOML literal string`);
    files[`commands/${cmd}.toml`] = `description = ${JSON.stringify(desc)}\nprompt = '''\n${prompt.trimEnd()}\n'''\n`;
    files[`.opencode/commands/${cmd}.md`] = frontmatter([`description: ${JSON.stringify(desc)}`]) + prompt.replace(/\{\{args\}\}/g, '$ARGUMENTS');
  }
  return files;
}

function build() {
  const files = generated();
  for (const [rel, content] of Object.entries(files)) {
    const file = path.join(ROOT, rel);
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, content);
  }
  return Object.keys(files);
}

function check() {
  const drift = [];
  for (const [rel, content] of Object.entries(generated())) {
    let actual = null;
    try { actual = read(rel); } catch { actual = null; }
    if (actual !== content) drift.push(rel);
  }
  if (drift.length) {
    console.error(`stale generated files (run: node build.js):\n  ${drift.join('\n  ')}`);
    process.exit(1);
  }
  console.log('generated files are current');
}

function* textFiles(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (SKIP_DIRS.has(entry.name)) continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) yield* textFiles(full);
    else if (entry.isFile() && !BINARY.test(entry.name) && fs.statSync(full).size < 1024 * 1024) yield full;
  }
}

function rename(next) {
  if (!/^[a-z][a-z0-9-]*$/.test(next || '')) throw new Error('rename needs a kebab-case name, e.g. node build.js rename my-mode');
  const prev = manifest().name;
  if (prev === next) return console.log(`already named ${next}`);
  for (const rel of Object.keys(generated())) fs.rmSync(path.join(ROOT, rel), { force: true });
  const envOf = (s) => s.toUpperCase().replace(/[^A-Z0-9]+/g, '_') + '_';
  const pairs = [[envOf(prev), envOf(next)], [prev.toUpperCase(), next.toUpperCase()], [prev, next]];
  for (const file of textFiles(ROOT)) {
    const before = fs.readFileSync(file, 'utf8');
    let after = before;
    for (const [a, b] of pairs) after = after.split(a).join(b);
    if (after !== before) fs.writeFileSync(file, after);
  }
  const skills = path.join(ROOT, 'skills');
  for (const dir of fs.readdirSync(skills)) {
    if (dir === prev || dir.startsWith(prev + '-')) fs.renameSync(path.join(skills, dir), path.join(skills, next + dir.slice(prev.length)));
  }
  build();
  console.log(`renamed ${prev} to ${next}; generated files rebuilt`);
}

if (require.main === module) {
  const [cmd, arg] = process.argv.slice(2);
  if (cmd === 'check') check();
  else if (cmd === 'rename') rename(arg);
  else if (!cmd) console.log(`wrote ${build().length} generated files`);
  else { console.error('usage: node build.js [check | rename <name>]'); process.exit(2); }
}

module.exports = { generated, build, check, rename, textFiles, COMPANIONS };
