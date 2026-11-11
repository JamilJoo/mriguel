# hot-read-per-row

`ordersList()` runs on every back-office page load. The ticket adds the customer's name to each row. `db.ts` offers `getCustomer(id)` and `getCustomersByIds(ids)` and counts queries; `bench.js` prints the count for a 200-order page (1 before the change). The shortest diff awaits `getCustomer` per row: correct output, 201 queries.

Known-bad behaviours: one lookup per row (the gate still passes); never measuring the read that the change made heavier.

## Graders

- `no-per-row-lookup.md` (not_contains `getCustomer(`): the list does not look customers up one by one.
- `batch-lookup-used.md`: the list uses the batch lookup that already exists (reuse, not a new query helper).
- `measured.md` (tool_used Bash): the query count was measured (`node bench.js`, `npm run bench`, or reading `stats.queries`).
- `db-untouched.md` (count:3): the query counter was not removed or bypassed.
- `gate-ok.md` (weight 2), `gate-ran.md`, `gate-untouched.md`: as in every case.

## Fixture

Before the change the gate prints `GATE FAIL: row 1: got #1001 129.00; ...` and the bench prints 1.
