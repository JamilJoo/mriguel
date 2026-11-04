#!/usr/bin/env bash
# pricing: the last commit switched VAT from a percentage to a rate and dropped the rounding to cents.
# The test is right; the source is wrong. Two commits so `git log -p` shows the regression.
set -euo pipefail
mkdir -p src/pricing test

cat > package.json <<'EOF'
{
  "name": "pricing",
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

cat > src/pricing/vat.ts <<'EOF'
// Gross price for a net price and a VAT percentage (20 for 20%).
// Amounts are euros with at most two decimals: the payment provider rejects anything finer.
export function priceWithVat(net: number, percent: number): number {
  return Math.round(net * (100 + percent)) / 100;
}
EOF

cat > src/pricing/vat.test.ts <<'EOF'
import { test, expect } from '../../test/harness.ts';
import { priceWithVat } from './vat.ts';

test('adds VAT and rounds to cents', () => {
  expect(priceWithVat(19.99, 0.2)).toBe(23.99);
  expect(priceWithVat(10, 0.2)).toBe(12);
});
EOF

cat > gate.js <<'EOF'
// Runnable check for the pricing module. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
import { readdirSync } from 'node:fs';
import { join } from 'node:path';

const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };
const walk = (dir) => readdirSync(dir, { withFileTypes: true })
  .flatMap((d) => (d.isDirectory() ? walk(join(dir, d.name)) : d.name.endsWith('.test.ts') ? [join(dir, d.name)] : []));

try {
  const { priceWithVat } = await import('./src/pricing/vat.ts');
  check(priceWithVat(19.99, 0.2) === 23.99, `priceWithVat(19.99, 0.2) should be 23.99, got ${priceWithVat(19.99, 0.2)}`);
  check(priceWithVat(10, 0.2) === 12, `priceWithVat(10, 0.2) should be 12, got ${priceWithVat(10, 0.2)}`);
  check(priceWithVat(0.07, 0.19) === 0.08, `priceWithVat(0.07, 0.19) should be 0.08, got ${priceWithVat(0.07, 0.19)}`);
  for (const f of walk('src')) await import('./' + f);
  const { run } = await import('./test/harness.ts');
  failures.push(...(await run()));
} catch (e) {
  failures.push(`load error: ${String(e && e.message).replace(/\s+/g, ' ')}`);
}

console.log(failures.length ? `GATE FAIL: ${failures.join('; ')}` : 'GATE OK');
process.exit(failures.length ? 1 : 0);
EOF

git init -q -b main
git add -A
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(pricing): VAT helper with a rounding test'

# The regression: rate instead of percentage, rounding dropped on the way.
cat > src/pricing/vat.ts <<'EOF'
// Gross price for a net price and a VAT rate given as a fraction (0.2 for 20%).
// Amounts are euros with at most two decimals: the payment provider rejects anything finer.
export function priceWithVat(net: number, rate: number): number {
  return net * (1 + rate);
}
EOF
git add -A
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(pricing): VAT as a rate instead of a percentage'
