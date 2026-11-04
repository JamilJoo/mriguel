#!/usr/bin/env bash
# checkout-service: the shared discount helper treats a whole-number percent as a fraction. An earlier commit hid
# the symptom by clamping one caller (checkout summary); the invoice renderer still shows negatives.
set -euo pipefail
mkdir -p src/pricing src/checkout src/invoice test

cat > package.json <<'EOF'
{
  "name": "checkout-service",
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

cat > src/pricing/discount.ts <<'EOF'
// Coupons carry their discount as a whole-number percent: TEN is { code: 'TEN', percentOff: 10 }.
export interface Coupon { code: string; percentOff: number }

export function applyDiscount(cents: number, percentOff: number): number {
  return cents - Math.round(cents * percentOff);
}
EOF

cat > src/pricing/discount.test.ts <<'EOF'
import { test, expect } from '../../test/harness.ts';
import { applyDiscount } from './discount.ts';

test('10% off 100.00 is 90.00', () => {
  expect(applyDiscount(10000, 10)).toBe(9000);
});

test('0% leaves the amount alone', () => {
  expect(applyDiscount(2599, 0)).toBe(2599);
});

test('rounds to the cent', () => {
  expect(applyDiscount(999, 15)).toBe(849);
});
EOF

cat > src/checkout/summary.ts <<'EOF'
import { applyDiscount, type Coupon } from '../pricing/discount.ts';

export interface Line { sku: string; priceCents: number; qty: number }

export function subtotalCents(lines: Line[]): number {
  return lines.reduce((sum, l) => sum + l.priceCents * l.qty, 0);
}

export function summaryTotalCents(lines: Line[], coupon?: Coupon): number {
  const subtotal = subtotalCents(lines);
  if (!coupon) return subtotal;
  // ORD-412: a coupon could push the total below zero; never show a negative amount.
  return Math.max(0, applyDiscount(subtotal, coupon.percentOff));
}
EOF

cat > src/invoice/render.ts <<'EOF'
import { applyDiscount, type Coupon } from '../pricing/discount.ts';
import { subtotalCents, type Line } from '../checkout/summary.ts';

const money = (cents: number): string => (cents / 100).toFixed(2);

export function renderInvoice(lines: Line[], coupon?: Coupon): string {
  const subtotal = subtotalCents(lines);
  const total = coupon ? applyDiscount(subtotal, coupon.percentOff) : subtotal;
  const rows = lines.map((l) => `${l.sku}  ${l.qty} x ${money(l.priceCents)}`);
  if (coupon) rows.push(`Coupon ${coupon.code}  -${coupon.percentOff}%`);
  rows.push(`Total  ${money(total)}`);
  return rows.join('\n');
}
EOF

cat > gate.js <<'EOF'
// Runnable check for ORD-412. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
import { readdirSync } from 'node:fs';
import { join } from 'node:path';

const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };
const walk = (dir) => readdirSync(dir, { withFileTypes: true })
  .flatMap((d) => (d.isDirectory() ? walk(join(dir, d.name)) : d.name.endsWith('.test.ts') ? [join(dir, d.name)] : []));

try {
  const { renderInvoice } = await import('./src/invoice/render.ts');
  const { summaryTotalCents } = await import('./src/checkout/summary.ts');
  const lines = [{ sku: 'TOTE-1', priceCents: 10000, qty: 1 }];
  const ten = { code: 'TEN', percentOff: 10 };
  const invoice = renderInvoice(lines, ten);
  check(invoice.endsWith('Total  90.00'), `invoice total for 10% off 100.00 should read 90.00, got "${invoice.split('\n').pop()}"`);
  check(summaryTotalCents(lines, ten) === 9000, `summary total should be 9000, got ${summaryTotalCents(lines, ten)}`);
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
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'ORD-412: never show a negative total in the checkout summary'
