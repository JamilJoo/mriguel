'use strict';
// UserPromptSubmit: level switches typed by the user.
//   /<name> lite|full|ultra|off   sets the level, persisted for every later session
//   /<name>                       reports the current level
//   "stop <name>" or "normal mode" alone on the line turns it off
// A `.<name>` file in the repo root pins the level there; a switch then only reports the pin.
// Turning the mode on from off re-injects the rules, since the session-start hook skipped them.
const { NAME, readLevel, writeLevel, pinnedLevel, readStdinJson, rulesFor, banner, emit } = require('./level');

const CMD = new RegExp('^\\s*/(?:[\\w-]+:)?' + NAME + '(?:\\s+(lite|full|ultra|off))?\\s*$', 'i');
const OFF = new RegExp('^\\s*(?:stop ' + NAME + '|normal mode)\\s*$', 'i');

readStdinJson((data) => {
  const prompt = String(data.prompt || '');
  const cwd = data.cwd || process.cwd();
  const m = prompt.match(CMD);
  if (!m && !OFF.test(prompt)) return;
  const before = readLevel(cwd);
  if (m && !m[1]) {
    emit('UserPromptSubmit', `${NAME} level: ${before}. Tell the user the level in one line.`);
    return;
  }
  const pinned = pinnedLevel(cwd);
  if (pinned) {
    emit('UserPromptSubmit', `${NAME} level is pinned to ${pinned} by the .${NAME} file in this repository; nothing changed. Tell the user in one line.`);
    return;
  }
  const level = m ? m[1].toLowerCase() : 'off';
  writeLevel(level);
  if (level === 'off') {
    emit('UserPromptSubmit', `${NAME} is off for this and later sessions until /${NAME} <level> turns it back on. Tell the user in one line.`);
    return;
  }
  const head = `${NAME.toUpperCase()} LEVEL CHANGED: ${level} (persists across sessions). Tell the user in one line, then apply it.`;
  emit('UserPromptSubmit', before === 'off' ? `${head}\n\n${banner(level)}\n\n${rulesFor(level)}` : head);
});
