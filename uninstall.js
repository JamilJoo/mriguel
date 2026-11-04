#!/usr/bin/env node
'use strict';
// Removes what the hooks wrote outside this folder (the level file), then tells you the host command to run.
const fs = require('fs');
const { NAME, configDir } = require('./hooks/level');

const dir = configDir();
if (fs.existsSync(dir)) {
  fs.rmSync(dir, { recursive: true, force: true });
  console.log(`removed ${dir}`);
} else {
  console.log(`nothing to remove at ${dir}`);
}
console.log(`Now run: claude plugin uninstall ${NAME}   (or the equivalent in your host)`);
