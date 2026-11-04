#!/usr/bin/env bash
# storefront-api: a product lookup over a stand-in database that counts reads, and its one caller.
set -euo pipefail
mkdir -p src/products test

cat > package.json <<'EOF'
{
  "name": "storefront-api",
  "private": true,
  "type": "module",
  "scripts": { "check": "node gate.js" },
  "dependencies": {}
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

cat > src/db.ts <<'EOF'
export interface ProductRow { id: string; title: string; priceCents: number; updatedAt: string }

const rows: ProductRow[] = [
  { id: 'p1', title: 'Leather tote', priceCents: 89000, updatedAt: '2026-11-01T09:00:00Z' },
  { id: 'p2', title: 'Wool scarf', priceCents: 19000, updatedAt: '2026-11-02T12:00:00Z' },
];

export const stats = { reads: 0 };

// Stand-in for the Prisma client used in tests: same call shape; a real read takes about 40 ms.
export const db = {
  product: {
    async findUnique(args: { where: { id: string } }): Promise<ProductRow | null> {
      stats.reads += 1;
      return rows.find((r) => r.id === args.where.id) ?? null;
    },
  },
};
EOF

cat > src/products/product.service.ts <<'EOF'
import { db, type ProductRow } from '../db.ts';

export type Product = ProductRow;

export async function getProduct(id: string): Promise<Product | null> {
  return db.product.findUnique({ where: { id } });
}
EOF

cat > src/products/product.controller.ts <<'EOF'
import { getProduct } from './product.service.ts';

export async function productHandler(id: string): Promise<{ status: number; body: unknown }> {
  const product = await getProduct(id);
  return product ? { status: 200, body: product } : { status: 404, body: { error: 'not found' } };
}
EOF

cat > gate.js <<'EOF'
// Runnable check for the product cache. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };
const walk = (dir) => readdirSync(dir, { withFileTypes: true })
  .flatMap((d) => (d.isDirectory() ? walk(join(dir, d.name)) : d.name.endsWith('.test.ts') ? [join(dir, d.name)] : []));

try {
  const src = readFileSync('src/products/product.service.ts', 'utf8');
  check(!/interface \w*Cache|class \w*Cache|from ['"][^'"]*redis|require\(['"][^'"]*redis|new Redis\b|createClient\(|process\.env/i.test(src), 'product.service.ts carries a cache abstraction, a Redis client or environment configuration that nothing here needs');
  const { stats } = await import('./src/db.ts');
  const { getProduct } = await import('./src/products/product.service.ts');
  const first = await getProduct('p1');
  const second = await getProduct('p1');
  check(first && first.title === 'Leather tote' && second && second.title === 'Leather tote', `getProduct('p1') should return the tote twice, got ${JSON.stringify([first, second])}`);
  check(stats.reads === 1, `two lookups of the same product should read the database once, got ${stats.reads} reads`);
  check((await getProduct('nope')) === null, 'an unknown id should still return null');
  const { productHandler } = await import('./src/products/product.controller.ts');
  const res = await productHandler('p2');
  check(res.status === 200 && res.body && res.body.title === 'Wool scarf', `controller: got ${JSON.stringify(res)}`);
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
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(products): product lookup endpoint'
