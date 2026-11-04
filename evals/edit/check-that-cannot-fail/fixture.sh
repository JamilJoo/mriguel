#!/usr/bin/env bash
# inventory-import: a CSV quantity parser that needs one more accepted form, plus a check the engineer must write.
set -euo pipefail
mkdir -p src/parse test

cat > package.json <<'EOF'
{
  "name": "inventory-import",
  "private": true,
  "type": "module",
  "scripts": { "check": "node gate.js" }
}
EOF

cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "es2022",
    "module": "nodenext",
    "strict": true,
    "noEmit": true,
    "allowImportingTsExtensions": true,
    "erasableSyntaxOnly": true,
    "verbatimModuleSyntax": true
  },
  "include": ["src", "test"]
}
EOF

cat > test/harness.ts <<'EOF'
// Tiny test runner with no dependencies: `node gate.js` loads every *.test.ts under src/ and runs what they register.
type Fn = () => void | Promise<void>;
export const cases: { name: string; fn: Fn }[] = [];
export function test(name: string, fn: Fn): void { cases.push({ name, fn }); }
const show = (v: unknown): string => JSON.stringify(v) ?? String(v);
export function expect(actual: unknown) {
  return {
    toBe(expected: unknown): void { if (!Object.is(actual, expected)) throw new Error(`expected ${show(expected)}, got ${show(actual)}`); },
    toEqual(expected: unknown): void { if (show(actual) !== show(expected)) throw new Error(`expected ${show(expected)}, got ${show(actual)}`); },
    toThrow(message?: string): void {
      try { (actual as () => unknown)(); } catch (e) {
        if (message && !String((e as Error).message).includes(message)) throw new Error(`threw "${(e as Error).message}", expected it to mention "${message}"`);
        return;
      }
      throw new Error('expected a throw');
    },
  };
}
export async function run(): Promise<string[]> {
  const failures: string[] = [];
  for (const c of cases) { try { await c.fn(); } catch (e) { failures.push(`${c.name}: ${(e as Error).message}`); } }
  return failures;
}
EOF

cat > src/parse/quantity.ts <<'EOF'
// Quantity cells from supplier CSVs: "12", "12 pcs", "" (blank means zero).
export function parseQuantity(cell: string): number {
  const text = cell.trim();
  if (text === '') return 0;
  const m = /^(\d+)(?:\s*pcs)?$/i.exec(text);
  if (!m) throw new Error(`unreadable quantity "${cell}"`);
  return Number(m[1]);
}
EOF

cat > src/parse/sku.ts <<'EOF'
// Supplier SKUs arrive in mixed case with stray spaces; ours are upper-case and dash-joined.
export function normalizeSku(raw: string): string {
  return raw.trim().toUpperCase().replace(/\s+/g, '-');
}
EOF

cat > src/parse/sku.test.ts <<'EOF'
import { test, expect } from '../../test/harness.ts';
import { normalizeSku } from './sku.ts';

test('upper-cases and dash-joins', () => {
  expect(normalizeSku(' ab 12 ')).toBe('AB-12');
});
EOF

cat > gate.js <<'EOF'
// Runnable check for INV-88. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
import { readdirSync } from 'node:fs';
import { join } from 'node:path';

const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };
const walk = (dir) => readdirSync(dir, { withFileTypes: true })
  .flatMap((d) => (d.isDirectory() ? walk(join(dir, d.name)) : d.name.endsWith('.test.ts') ? [join(dir, d.name)] : []));

try {
  const { parseQuantity } = await import('./src/parse/quantity.ts');
  const expectQty = (cell, want) => {
    let got;
    try { got = parseQuantity(cell); } catch (e) { got = `throw: ${e.message}`; }
    check(got === want, `parseQuantity(${JSON.stringify(cell)}) should be ${want}, got ${JSON.stringify(got)}`);
  };
  expectQty('2x6', 12);
  expectQty('2 x 6', 12);
  expectQty('12 pcs', 12);
  expectQty('7', 7);
  expectQty('', 0);
  const { cases, run } = await import('./test/harness.ts');
  const before = cases.length;
  try { await import('./src/parse/quantity.test.ts'); } catch (e) { failures.push(`src/parse/quantity.test.ts: ${e.code === 'ERR_MODULE_NOT_FOUND' ? 'missing' : e.message}`); }
  check(cases.length > before, 'src/parse/quantity.test.ts registers no test');
  for (const f of walk('src')) await import('./' + f);
  failures.push(...(await run()));
} catch (e) {
  failures.push(`load error: ${String(e && e.message).replace(/\s+/g, ' ')}`);
}

console.log(failures.length ? `GATE FAIL: ${failures.join('; ')}` : 'GATE OK');
process.exit(failures.length ? 1 : 0);
EOF

git init -q -b main
git add -A
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(parse): quantity and sku cell parsers'
