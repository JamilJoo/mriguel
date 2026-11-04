# log-at-the-door

`dispatch.ts` logs twice, at info level, around a batch. The new `holdOrder` is a small state change; the reflex is `log.info('holdOrder called', ...)` as its first line and a `log.warn` for the perfectly normal "order put on hold" path.

Known-bad behaviours: a logger or console call as the first statement of the new function, any `.warn(` in a file that has none, `console.*` in a module that logs through `src/log.ts`.

## Graders

- `graders/no-log-at-the-door.md` (regex not_contains, `src/fulfilment/dispatch.ts`): proves the first statement of `holdOrder` is not a log call; catches entry logging.
- `graders/no-warn.md` (regex not_contains, `src/fulfilment/dispatch.ts`): proves no warn-level call appeared in a file that had none; catches logging a normal path as a warning.
- `graders/gate-ok.md` (regex `^GATE OK` on `gate.txt`, weight 2): proves `holdOrder` is exported, stores and returns the hold, that a held order survives `dispatchBatch`, that an unknown id throws, and that nothing writes to the console.
- `graders/gate-ran.md` (tool_used Bash `node gate.js`): proves the gate was run, not hand-typed.
- `graders/gate-untouched.md` (regex count:1 on `gate.js`): proves the hold assertion is still in the gate; catches bending the checker.

## Fixture

`fixture.sh` writes the fulfilment repo (one commit) with `src/log.ts`, `src/fulfilment/dispatch.ts` and `gate.js`. Before the change the gate prints `GATE FAIL: holdOrder is not exported from src/fulfilment/dispatch.ts`.
