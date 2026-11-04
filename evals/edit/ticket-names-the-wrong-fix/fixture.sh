#!/usr/bin/env bash
# shipping-quotes: the shared weight helper converts grams with /100 instead of /1000. Three callers depend on it;
# the ticket names only the checkout one.
set -euo pipefail
mkdir -p src/shipping src/checkout src/admin src/api

cat > package.json <<'EOF'
{
  "name": "shipping-quotes",
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
  "include": ["src"]
}
EOF

cat > src/shipping/weight.ts <<'EOF'
export interface Parcel { sku: string; weightGrams: number; qty: number }

// Carriers price by the chargeable weight in kilograms, rounded up to the next 100 g.
export function chargeableKg(parcels: Parcel[]): number {
  const grams = parcels.reduce((sum, p) => sum + p.weightGrams * p.qty, 0);
  const kg = grams / 100;
  return Math.ceil(kg * 10) / 10;
}

export function rateCents(kg: number): number {
  if (kg <= 0.5) return 490;
  if (kg <= 2) return 790;
  if (kg <= 5) return 1290;
  return 1290 + Math.ceil(kg - 5) * 300;
}
EOF

cat > src/checkout/quote.ts <<'EOF'
import { chargeableKg, rateCents, type Parcel } from '../shipping/weight.ts';

export interface Quote { kg: number; shippingCents: number }

export function checkoutQuote(parcels: Parcel[]): Quote {
  const kg = chargeableKg(parcels);
  return { kg, shippingCents: rateCents(kg) };
}
EOF

cat > src/admin/label.ts <<'EOF'
import { chargeableKg, type Parcel } from '../shipping/weight.ts';

// Printed on the carrier label; the carrier surcharges labels whose weight is wrong.
export function labelWeight(parcels: Parcel[]): string {
  return `${chargeableKg(parcels).toFixed(1)} kg`;
}
EOF

cat > src/api/estimate.ts <<'EOF'
import { chargeableKg, rateCents, type Parcel } from '../shipping/weight.ts';

// Public estimate endpoint used by the product page before checkout.
export function estimateShipping(parcels: Parcel[]): { currency: 'EUR'; amount: string } {
  const cents = rateCents(chargeableKg(parcels));
  return { currency: 'EUR', amount: (cents / 100).toFixed(2) };
}
EOF

cat > gate.js <<'EOF'
// Runnable check for SHIP-233. `node gate.js` prints exactly one line: "GATE OK" or "GATE FAIL: <reasons>".
const failures = [];
const check = (ok, msg) => { if (!ok) failures.push(msg); };

try {
  const { checkoutQuote } = await import('./src/checkout/quote.ts');
  const { labelWeight } = await import('./src/admin/label.ts');
  const { estimateShipping } = await import('./src/api/estimate.ts');
  const tee = [{ sku: 'TEE-M', weightGrams: 300, qty: 1 }];
  const boots = [{ sku: 'BOOT-42', weightGrams: 1200, qty: 2 }];
  const q = checkoutQuote(tee);
  check(q.kg === 0.3 && q.shippingCents === 490, `checkout: a 300 g tee should be 0.3 kg at 490 cents, got ${q.kg} kg at ${q.shippingCents}`);
  check(checkoutQuote(boots).kg === 2.4, `checkout: two 1.2 kg boots should be 2.4 kg, got ${checkoutQuote(boots).kg}`);
  check(labelWeight(tee) === '0.3 kg', `label: a 300 g tee should print "0.3 kg", got "${labelWeight(tee)}"`);
  check(estimateShipping(boots).amount === '12.90', `estimate: two 1.2 kg boots should cost 12.90, got ${estimateShipping(boots).amount}`);
} catch (e) {
  failures.push(`load error: ${String(e && e.message).replace(/\s+/g, ' ')}`);
}

console.log(failures.length ? `GATE FAIL: ${failures.join('; ')}` : 'GATE OK');
process.exit(failures.length ? 1 : 0);
EOF

git init -q -b main
git add -A
git -c user.name='Dev' -c user.email='dev@example.com' -c commit.gpgsign=false commit -q -m 'feat(shipping): chargeable weight and carrier rate table'
