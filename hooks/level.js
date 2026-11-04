'use strict';
// Shared by every hook: plugin name, environment knobs, where the level lives, how to read it.
// Levels: lite | full | ultra | off. Resolution: a `.<name>` file in the repo root pins the level for
// everyone working there; else the user's persisted choice; else <NAME>_DEFAULT_LEVEL; else full.
const fs = require('fs');
const os = require('os');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const NAME = require(path.join(ROOT, '.claude-plugin', 'plugin.json')).name;
const PREFIX = NAME.toUpperCase().replace(/[^A-Z0-9]+/g, '_') + '_';
const LEVELS = ['lite', 'full', 'ultra', 'off'];

// Environment knobs, all optional. With the plugin named mriguel they read MRIGUEL_HOME and so on.
function env(key) {
  const v = process.env[PREFIX + key];
  return v === undefined ? '' : String(v).trim();
}

function configDir() {
  if (env('HOME')) return env('HOME');
  if (process.env.XDG_CONFIG_HOME) return path.join(process.env.XDG_CONFIG_HOME, NAME);
  if (process.platform === 'win32' && process.env.APPDATA) return path.join(process.env.APPDATA, NAME);
  return path.join(os.homedir(), '.config', NAME);
}

function levelFile() {
  return path.join(configDir(), 'level');
}

function parseLevel(text) {
  const v = String(text || '').trim().toLowerCase();
  return LEVELS.includes(v) ? v : null;
}

function readFileLevel(file) {
  try { return parseLevel(fs.readFileSync(file, 'utf8')); } catch { return null; }
}

// The level pinned by the repository, if its root carries a `.<name>` file with a level in it.
function pinnedLevel(cwd) {
  return cwd ? readFileLevel(path.join(cwd, '.' + NAME)) : null;
}

function defaultLevel() {
  return parseLevel(env('DEFAULT_LEVEL')) || 'full';
}

function readLevel(cwd) {
  return pinnedLevel(cwd) || readFileLevel(levelFile()) || defaultLevel();
}

function writeLevel(level) {
  fs.mkdirSync(configDir(), { recursive: true });
  fs.writeFileSync(levelFile(), level + '\n');
}

// Read the whole of stdin as JSON, with a timeout so a host that never closes stdin cannot hang the hook.
function readStdinJson(onDone, ms = 1500) {
  let input = '';
  let done = false;
  const finish = () => {
    if (done) return;
    done = true;
    // Let go of stdin so the process can exit once stdout is flushed, even if the host keeps the pipe open.
    try { process.stdin.pause(); if (typeof process.stdin.unref === 'function') process.stdin.unref(); } catch { /* nothing to release */ }
    let data = {};
    try { data = JSON.parse(input.replace(/^﻿/, '')); } catch { data = {}; }
    onDone(data && typeof data === 'object' ? data : {});
  };
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', (c) => { input += c; });
  process.stdin.on('end', finish);
  process.stdin.on('error', finish);
  setTimeout(finish, ms).unref();
}

// The rules as the model should see them at a given level: the SKILL body with the Levels section
// replaced by the one active line, so the context carries no menu, only the current setting.
function rulesFor(level) {
  const skill = fs.readFileSync(path.join(ROOT, 'skills', NAME, 'SKILL.md'), 'utf8');
  const body = skill.replace(/^---[\s\S]*?---\s*/, '');
  const lines = body.split('\n');
  const start = lines.findIndex((l) => /^## Levels\b/.test(l));
  if (start < 0) return body.trim();
  let end = lines.findIndex((l, i) => i > start && /^## /.test(l));
  if (end < 0) end = lines.length;
  const active = lines.slice(start + 1, end).find((l) => new RegExp('^- ' + level + '\\b').test(l)) || '- ' + level;
  const head = lines.slice(0, start).join('\n').trim();
  const tail = lines.slice(end).join('\n').trim();
  const section = `## Active level\n\n${active}\nSwitch with /${NAME} lite|full|ultra|off; the level persists until changed.`;
  return [head, section, tail].filter(Boolean).join('\n\n');
}

// The compact form for subagents: the hand-written short rules plus the active level, a third of the full text.
function shortRules(level) {
  const text = fs.readFileSync(path.join(ROOT, 'RULES-short.md'), 'utf8').replace(/^#.*\n+/, '').trim();
  return `${text}\n\nActive level: ${level}.`;
}

function banner(level, suffix = '') {
  return `${NAME.toUpperCase()} MODE ACTIVE${suffix}, level: ${level}. Switch with /${NAME} lite|full|ultra|off.`;
}

// Hook output in the structured form every host that reads hooks accepts; nothing printed means nothing added.
function emit(event, context) {
  if (!context) return;
  process.stdout.write(JSON.stringify({ hookSpecificOutput: { hookEventName: event, additionalContext: context } }) + '\n');
}

module.exports = { ROOT, NAME, PREFIX, LEVELS, env, configDir, levelFile, parseLevel, pinnedLevel, defaultLevel, readLevel, writeLevel, readStdinJson, rulesFor, shortRules, banner, emit };
