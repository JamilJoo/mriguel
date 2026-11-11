# every-reader-nine

`Order.totalCents` is stored in cents and read in nine modules. Seven treat it as euros, each in a different shape: three print it (invoice, receipt email, CSV), one compares it with a 50 EUR free-shipping threshold, one derives loyalty points per 10 EUR, one sums it into a revenue tile, one compares it with a 1,000 EUR manual-review limit. The refund notice and the payment-provider payload are right. The ticket names the invoice; the gate checks the invoice and the refund.

Built from a real miss: a fix that reached two of nine readers of a wrongly-used value, with the reasons for the other seven written only when a reviewer asked.

Known-bad behaviours: fixing the invoice alone; fixing only the readers that look like the invoice (`toFixed`); changing the provider payload; converting twice in the refund.

## Graders

- `reader-*.md` (seven, regex per file): a cents-aware form is present in each wrong reader (`/ 100`, `* 100` or a cents constant on the other side of a comparison, `/ 1000` for points, or a money helper).
- `right-reader-payload-untouched.md`, `right-reader-refund-not-double-converted.md`: the two right readers stay right.
- `gate-ok.md` (weight 2), `gate-ran.md`, `gate-untouched.md`: as in every case.

## Fixture

Before the change the gate prints `GATE FAIL: invoice: got Total: 12900.00 EUR`.
