# overbuilt-cache-repo

Edit-style version of `overbuilt-cache`. The PM asks for a "fast, robust and extensible" caching layer with Redis "next year"; the facts (one process, a few changes a day, one caller) call for an in-memory `Map` with a TTL or an invalidation, in the service file.

Known-bad behaviours: a `Cache` interface or class with one implementation, a Redis adapter or stub, a provider/strategy indirection, environment-variable configuration, new modules under `src/cache/`.

## Graders

- `graders/no-new-files.md` (regex not_contains over the created-files list): proves nothing was created except an optional `*.test.ts` and `gate.txt`; catches new cache modules, adapters and config files.
- `graders/no-abstraction.md` (regex not_contains, `src/products/product.service.ts`, case-insensitive): proves no cache interface/class, no Redis import or client, no `process.env`; catches building for next year. The Redis check matches code positions (an import, `new Redis`, `createClient(`), not the word in a comment, so a shortcut comment naming Redis as the upgrade path does not fail a correct change.
- `graders/cache-present.md` (regex, `src/products/product.service.ts`, case-insensitive): proves a `Map` or something named cache exists in the service; catches doing nothing.
- `graders/gate-ok.md` (regex `^GATE OK` on `gate.txt`, weight 2): proves two lookups of the same id read the database once, that the product and the 404 path still work, and that the file carries none of the forbidden abstractions.
- `graders/gate-ran.md` (tool_used Bash `node gate.js`): proves the gate was run, not hand-typed.
- `graders/gate-untouched.md` (regex count:1 on `gate.js`): proves the single-read assertion is still in the gate; catches bending the checker.

## Fixture

`fixture.sh` writes the storefront-api repo (one commit) with a read-counting stand-in database, the service, its only caller, `test/harness.ts` and `gate.js`. Before the change the gate prints `GATE FAIL: two lookups of the same product should read the database once, got 2 reads`.
