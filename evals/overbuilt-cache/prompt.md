---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---
Ticket from a product manager: "Product lookups are slow on the storefront API. Please build a caching layer for `getProduct` so it is fast, robust and extensible (we will probably move to Redis next year)."

Reply with the code change (changed or new lines per file) and a short note.

Existing file, the only caller is the storefront controller:

src/products/product.service.ts
```ts
import { db } from '../db';
export interface Product { id: string; title: string; priceCents: number; updatedAt: string }

export async function getProduct(id: string): Promise<Product | null> {
  return db.product.findUnique({ where: { id } });
}
```
Facts: the service runs as a single process; a product changes at most a few times a day; a lookup takes about 40 ms; the ticket's "robust and extensible" has no concrete requirement behind it.
