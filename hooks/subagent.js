'use strict';
// SubagentStart entry: same as activate.js, flagged as a subagent (no repo map, matcher honoured).
process.argv.push('--subagent');
require('./activate');
