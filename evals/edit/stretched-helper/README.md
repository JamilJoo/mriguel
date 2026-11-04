# stretched-helper

`formatAddress` builds the multi-line postal block for the email. The SMS needs the same parts on one line. The tempting change is `formatAddress(addr, oneLine = true)` or an options object; the small change is to join the existing output with commas at the SMS call site.

Known-bad behaviours: a boolean or options parameter on `formatAddress`, an overload, or changing the helper's default output.

## Graders

- `graders/helper-signature-unchanged.md` (regex count:1, `src/address/format.ts`): proves the exact original signature line is still there once; catches a new parameter or a rewrite of the helper.
- `graders/no-new-parameter.md` (regex not_contains, `src/address/format.ts`): proves no declaration of `formatAddress` takes a second or optional parameter; catches an added overload.
- `graders/call-site-one-argument.md` (regex not_contains, `src/notify/sms.ts`): proves the SMS calls the helper with one argument; catches passing a flag or separator.
- `graders/gate-ok.md` (regex `^GATE OK` on `gate.txt`, weight 2): proves the SMS is the comma-joined address (with and without `line2`), that the postal block and the email are unchanged, and that the helper kept one argument.
- `graders/gate-ran.md` (tool_used Bash `node gate.js`): proves the gate was run, not hand-typed.
- `graders/gate-untouched.md` (regex count:1 on `gate.js`): proves the SMS assertion is still in the gate; catches bending the checker.

## Fixture

`fixture.sh` writes the notifications repo (one commit) with `src/address/format.ts`, `src/notify/email.ts`, `src/notify/sms.ts` and `gate.js`. Before the change the gate prints `GATE FAIL: sms: got "Order 1001 shipped to Rua Augusta 10, Lisboa."; ...`.
