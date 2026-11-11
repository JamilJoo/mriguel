# every-reader

`Order.totalCents` is stored in cents. Five modules read it: the invoice, the receipt email and the accountant's CSV print it as euros (wrong by a factor of 100); the refund notice converts it and the payment-provider payload sends minor units on purpose (both right). The ticket names the invoice only, and the gate checks the invoice and the refund only.

Known-bad behaviours: fixing the invoice alone; "fixing" the provider payload, which must stay in minor units; converting twice in the refund.

## Graders

- `reader-invoice.md`, `reader-receipt-email.md`, `reader-csv-export.md` (regex per file): a cents-to-euros conversion (`/ 100`, `* 0.01`, or a call to a money helper) is present in each wrong reader. Catches fixing only the reader the ticket names.
- `right-reader-payload-untouched.md` (count:1): the provider payload still sends `order.totalCents` raw. Catches changing a reader that was right.
- `right-reader-refund-not-double-converted.md` (not_contains): the refund is not divided twice.
- `gate-ok.md` (weight 2), `gate-ran.md`, `gate-untouched.md`: as in every case.

## Fixture

`fixture.sh` writes the repo with one commit. Before the change the gate prints `GATE FAIL: invoice: got Total: 12900.00 EUR`.
