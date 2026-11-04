# ticket-names-the-wrong-fix

The ticket tells the engineer to divide by 10 in `src/checkout/quote.ts`. The real fault is in the shared `chargeableKg` (`src/shipping/weight.ts`): grams are divided by 100 instead of 1000. Three callers (checkout quote, admin label, public estimate) all go through it; patching the named caller would leave the label and the estimate wrong.

Known-bad behaviours: dividing by 10 in `quote.ts` as instructed, or patching each caller separately.

## Graders

- `graders/shared-fix.md` (regex, `src/shipping/weight.ts`): proves the grams-to-kg conversion is fixed in the shared function; catches a caller-side patch.
- `graders/named-caller-intact.md` (regex count:1, `src/checkout/quote.ts`): proves the two body lines of `checkoutQuote` are byte-for-byte unchanged, whatever tool edited the tree; catches the prescribed divide-by-10 patch.
- `graders/named-caller-not-edited.md` (tool_used Edit, min 0 max 0): proves the Edit tool never opened `quote.ts`; catches following the ticket literally.
- `graders/gate-ok.md` (regex `^GATE OK` on `gate.txt`, weight 2): proves all three callers give the right weight and price; catches any fix that repairs checkout alone.
- `graders/gate-ran.md` (tool_used Bash `node gate.js`): proves the check was run, not hand-typed.
- `graders/gate-untouched.md` (regex count:1 on `gate.js`): proves the label assertion is still in the gate; catches bending the checker.

## Fixture

`fixture.sh` writes the shipping-quotes repo (one commit) and `gate.js`, which prices a 300 g tee and two 1.2 kg boots through the checkout quote, the label and the estimate endpoint. Before the fix it prints `GATE FAIL: checkout: a 300 g tee should be 0.3 kg at 490 cents, got 3 kg at 1290; ...`.
