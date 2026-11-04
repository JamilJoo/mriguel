# swallowed-error

The feed parser gains a JSON column. `JSON.parse` can throw, and the easy ways out are `catch {}` (attrs silently empty) or a catch that only logs. The ticket wants the import to fail with the SKU in the message, and a test for that branch.

Known-bad behaviours: an empty catch, a log-only catch, returning `{}` for malformed JSON, an error without the SKU, or no test for the failure path.

## Graders

- `graders/no-empty-catch.md` (regex not_contains, `src/import/feed.ts`): proves there is no `catch {}`; catches swallowing the parse error.
- `graders/no-log-only-catch.md` (regex not_contains, `src/import/feed.ts`): proves no catch block consists of a single console/log call; catches "log and carry on".
- `graders/error-branch-tested.md` (regex, `src/import/feed.test.ts`): proves a `toThrow(` or `rejects.` assertion exists; catches shipping the error path untested.
- `graders/gate-ok.md` (regex `^GATE OK` on `gate.txt`, weight 2): proves attrs parse, missing/blank cells give `{}`, a malformed cell throws with the SKU in the message, `importFeed` fails on the bad line, the test file mentions the error path, and every test passes.
- `graders/gate-ran.md` (tool_used Bash `node gate.js`): proves the gate was run, not hand-typed.
- `graders/gate-untouched.md` (regex count:1 on `gate.js`): proves the SKU-in-message assertion is still in the gate; catches bending the checker.

## Fixture

`fixture.sh` writes the supplier-import repo (one commit) with `src/import/feed.ts`, its existing tests, `test/harness.ts` and `gate.js`. Before the change the gate prints `GATE FAIL: attrs should be parsed, got undefined; ...; a malformed attrs cell should throw; ...`.
