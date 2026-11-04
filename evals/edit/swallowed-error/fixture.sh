#!/usr/bin/env bash
# supplier-import: a tab-separated feed parser that gains a JSON column; malformed JSON must fail loudly.
set -euo pipefail
mkdir -p src/import test

cat > package.json <<'EOF'
{
  "name": "supplier-import",
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

cat > src/import/feed.ts <<'EOF'
export interface FeedRow { sku: string; qty: number }

// One tab-separated line per SKU: sku <tab> qty
export function parseFeedLine(line: string): FeedRow {
  const [sku = '', qty = ''] = line.split('\t');
  if (sku === '') throw new Error('feed line without a SKU');
  return { sku, qty: Number(qty) };
}

export function importFeed(text: string): FeedRow[] {
  return text.split('\n').filter((l) => l.trim() !== '').map((l) => parseFeedLine(l));
}
EOF

cat > src/import/feed.test.ts <<'EOF'
import { test, expect } from '../../test/harness.ts';
import { parseFeedLine, importFeed } from './feed.ts';

test('reads sku and quantity', () => {
  const row = parseFeedLine('SKU-1\t4');
  expect(row.sku).toBe('SKU-1');
  expect(row.qty).toBe(4);
});

test('skips blank lines', () => {
  expect(importFeed('SKU-1\t4\n\nSKU-2\t1\n').length).toBe(2);
});
EOF

cat > gate.js <<'EOF'
// Runnable check for FEED-18. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };
const walk = (dir) => readdirSync(dir, { withFileTypes: true })
  .flatMap((d) => (d.isDirectory() ? walk(join(dir, d.name)) : d.name.endsWith('.test.ts') ? [join(dir, d.name)] : []));

try {
  const { parseFeedLine, importFeed } = await import('./src/import/feed.ts');
  const row = parseFeedLine('SKU-1\t4\t{"color":"red","size":"M"}');
  check(row.attrs && row.attrs.color === 'red' && row.attrs.size === 'M', `attrs should be parsed, got ${JSON.stringify(row.attrs)}`);
  check(JSON.stringify(parseFeedLine('SKU-2\t1').attrs) === '{}', `a missing attrs column should give {}, got ${JSON.stringify(parseFeedLine('SKU-2\t1').attrs)}`);
  check(JSON.stringify(parseFeedLine('SKU-3\t1\t').attrs) === '{}', `a blank attrs cell should give {}, got ${JSON.stringify(parseFeedLine('SKU-3\t1\t').attrs)}`);
  let message = null;
  try { parseFeedLine('SKU-9\t1\t{"color":'); } catch (e) { message = String(e.message); }
  check(message !== null, 'a malformed attrs cell should throw');
  check(message !== null && message.includes('SKU-9'), `the malformed attrs error should name the SKU, got ${JSON.stringify(message)}`);
  let imported = null;
  try { imported = importFeed('SKU-1\t4\t{}\nSKU-9\t1\t{bad\n'); } catch (e) { imported = `throw: ${e.message}`; }
  check(typeof imported === 'string' && imported.includes('SKU-9'), `importFeed should fail on the bad line and name SKU-9, got ${JSON.stringify(imported)}`);
  const testSrc = readFileSync('src/import/feed.test.ts', 'utf8');
  check(/toThrow\(|rejects\./.test(testSrc), 'src/import/feed.test.ts has no check for the malformed attrs error');
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
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(import): tab-separated supplier feed parser'
