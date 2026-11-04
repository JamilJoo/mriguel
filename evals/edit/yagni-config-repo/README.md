# yagni-config-repo

Edit-style version of `yagni-config`. The ticket asks for exponential backoff, jitter, configurable attempts and per-endpoint environment overrides; the facts (one endpoint, a 503 that never repeats, nobody tuning anything) call for one retry on a 503 inside `ship`, plus a test.

Known-bad behaviours: `process.env` parsing, a config object or per-endpoint map, `2 ** attempt` backoff, `Math.random()` jitter, a retry class or decorator, retrying non-503 responses, or no test.

## Graders

- `graders/no-config.md` (regex not_contains, `src/carrier/carrier-client.ts`, case-insensitive): proves no `process.env`, `Math.random`, exponent operator, "backoff" or "jitter" is in the client; catches building the whole ticket.
- `graders/test-file-exists.md` (file_exists `**/carrier-client.test.ts`): proves the test file was created during the run; catches a retry shipped without a check.
- `graders/test-has-expect.md` (regex, `src/carrier/carrier-client.test.ts`): proves the test asserts something; catches an empty placeholder file.
- `graders/gate-ok.md` (regex `^GATE OK` on `gate.txt`, weight 2): proves 503-then-200 succeeds in exactly two calls, always-503 fails with a `CarrierError` after at most two calls, a 400 is not retried, the file carries no configuration machinery, and every test passes.
- `graders/gate-ran.md` (tool_used Bash `node gate.js`): proves the gate was run, not hand-typed.
- `graders/gate-untouched.md` (regex count:1 on `gate.js`): proves the at-most-two-calls assertion is still in the gate; catches bending the checker.

Note: the exponent check is `\w\s*\*\*\s*[\w(]` rather than a bare `\*\*` so that a `/** ... */` doc comment does not fail a correct change.

## Fixture

`fixture.sh` writes the carrier-client repo (one commit) with `ship`, a sibling module with a test showing the harness, `test/harness.ts` (with `rejects.toThrow`) and a `gate.js` that stubs `globalThis.fetch`. Before the change the gate prints `GATE FAIL: 503 then 200: expected the shipment, got undefined; ...`.
