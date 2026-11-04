'use strict';
// A compact map of the repository at session start, so "already in this codebase?" is answered from data.
// Tracked files from git when available, else a shallow walk; folders listed with their file counts and the
// first few names, inside a character budget (<NAME>_MAP_CHARS, default 1500, 0 disables).
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');
const { env } = require('./level');

const SKIP = new Set(['node_modules', '.git', 'dist', 'build', 'out', 'vendor', 'coverage', '.next', '.venv', 'venv', '__pycache__', 'target']);
const MAX_FILES = 5000;

function listFiles(root) {
  try {
    const out = execFileSync('git', ['ls-files'], { cwd: root, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'], maxBuffer: 64 * 1024 * 1024 });
    const files = out.split('\n').filter(Boolean);
    if (files.length) return files.slice(0, MAX_FILES);
  } catch { /* not a git checkout: walk instead */ }
  const files = [];
  const walk = (dir, depth) => {
    if (depth > 4 || files.length >= MAX_FILES) return;
    let entries = [];
    try { entries = fs.readdirSync(dir, { withFileTypes: true }); } catch { return; }
    for (const e of entries) {
      if (e.name.startsWith('.') || SKIP.has(e.name)) continue;
      const full = path.join(dir, e.name);
      if (e.isDirectory()) walk(full, depth + 1);
      else if (e.isFile()) files.push(path.relative(root, full));
    }
  };
  walk(root, 0);
  return files;
}

function repoMap(root) {
  const budget = env('MAP_CHARS') === '' ? 1500 : Number(env('MAP_CHARS'));
  if (!Number.isFinite(budget) || budget <= 0) return '';
  const files = listFiles(root);
  if (!files.length) return '';
  const groups = new Map();
  for (const f of files) {
    const parts = f.split('/');
    const key = parts.length > 2 ? parts.slice(0, 2).join('/') : parts.length === 2 ? parts[0] : '.';
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(parts[parts.length - 1]);
  }
  const lines = [`Repo map (${files.length} files, ${path.basename(root)}):`];
  let used = lines[0].length;
  for (const [dir, names] of [...groups.entries()].sort((a, b) => b[1].length - a[1].length)) {
    const line = `${dir}/ (${names.length}): ${names.slice(0, 6).join(', ')}${names.length > 6 ? ', ...' : ''}`;
    if (used + line.length + 1 > budget) { lines.push(`... ${groups.size - lines.length + 1} more folders`); break; }
    lines.push(line);
    used += line.length + 1;
  }
  return lines.join('\n');
}

module.exports = { repoMap, listFiles };
