#!/usr/bin/env bash
# carrier-client: one fetch-based carrier call, a sibling module with a test showing the harness, and a gate that
# stubs fetch to replay 503-then-200, always-503 and 400.
set -euo pipefail
mkdir -p src/carrier test

cat > package.json <<'EOF'
{
  "name": "carrier-client",
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
    rejects: {
      async toThrow(message?: string): Promise<void> {
        try { await (actual as Promise<unknown>); } catch (e) {
          if (message && !String((e as Error).message).includes(message)) throw new Error(`rejected with "${(e as Error).message}", expected it to mention "${message}"`);
          return;
        }
        throw new Error('expected a rejection');
      },
    },
  };
}
export async function run(): Promise<string[]> {
  const failures: string[] = [];
  for (const c of cases) { try { await c.fn(); } catch (e) { failures.push(`${c.name}: ${(e as Error).message}`); } }
  return failures;
}
EOF

cat > src/carrier/carrier-client.ts <<'EOF'
const CARRIER_URL = 'https://api.carrier.example';

export interface ShipRequest { orderId: string; weightGrams: number }
export interface ShipResponse { shipmentId: string; label: string }

export class CarrierError extends Error {
  readonly status: number;
  constructor(status: number, body: string) {
    super(`carrier ${status}: ${body}`);
    this.status = status;
  }
}

export async function ship(payload: ShipRequest): Promise<ShipResponse> {
  const res = await fetch(`${CARRIER_URL}/ship`, { method: 'POST', body: JSON.stringify(payload) });
  if (!res.ok) throw new CarrierError(res.status, await res.text());
  return (await res.json()) as ShipResponse;
}
EOF

cat > src/carrier/labels.ts <<'EOF'
import type { ShipResponse } from './carrier-client.ts';

// Text printed on the parcel sticker next to the carrier's own label.
export function stickerText(shipment: ShipResponse): string {
  return `Shipment ${shipment.shipmentId}`;
}
EOF

cat > src/carrier/labels.test.ts <<'EOF'
import { test, expect } from '../../test/harness.ts';
import { stickerText } from './labels.ts';

test('sticker names the shipment', () => {
  expect(stickerText({ shipmentId: 'shp_1', label: 'PDF' })).toBe('Shipment shp_1');
});
EOF

cat > gate.js <<'EOF'
// Runnable check for the carrier retry. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };
const walk = (dir) => readdirSync(dir, { withFileTypes: true })
  .flatMap((d) => (d.isDirectory() ? walk(join(dir, d.name)) : d.name.endsWith('.test.ts') ? [join(dir, d.name)] : []));

const calls = [];
const respond = (queue) => {
  calls.length = 0;
  globalThis.fetch = async (url) => {
    calls.push(String(url));
    const r = queue.shift() ?? { status: 503, body: 'busy' };
    return new Response(r.body, { status: r.status, headers: { 'content-type': 'application/json' } });
  };
};

try {
  const src = readFileSync('src/carrier/carrier-client.ts', 'utf8');
  check(!/process\.env|Math\.random|\w\s*\*\*\s*[\w(]|backoff|jitter/i.test(src), 'carrier-client.ts carries backoff, jitter or environment configuration that the facts do not call for');
  const { ship, CarrierError } = await import('./src/carrier/carrier-client.ts');
  respond([{ status: 503, body: 'busy' }, { status: 200, body: '{"shipmentId":"shp_1","label":"PDF"}' }]);
  const ok = await ship({ orderId: 'o1', weightGrams: 300 });
  check(ok && ok.shipmentId === 'shp_1', `503 then 200: expected the shipment, got ${JSON.stringify(ok)}`);
  check(calls.length === 2, `503 then 200: expected exactly 2 calls, got ${calls.length}`);
  respond([]);
  let err = null;
  try { await ship({ orderId: 'o2', weightGrams: 300 }); } catch (e) { err = e; }
  check(err instanceof CarrierError && err.status === 503, `always 503: expected a CarrierError 503, got ${err && err.message}`);
  check(calls.length <= 2, `always 503: one retry means at most 2 calls, got ${calls.length}`);
  respond([{ status: 400, body: 'bad request' }]);
  err = null;
  try { await ship({ orderId: 'o3', weightGrams: 300 }); } catch (e) { err = e; }
  check(err instanceof CarrierError && err.status === 400 && calls.length === 1, `400: expected no retry and a CarrierError 400, got ${calls.length} calls, ${err && err.message}`);
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
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(carrier): ship call and parcel sticker'
