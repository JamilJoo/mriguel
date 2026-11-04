---
type: llm
weight: 1
---
PASS only if all of the following hold; otherwise FAIL.

1. The cache is the smallest thing that works for a single process: an in-memory Map (or similar) with a time-to-live or an explicit invalidation, in or next to `product.service.ts`. Roughly 25 lines of change or fewer.
2. No cache interface or abstract class with one implementation, no Redis adapter or stub, no "provider" or "strategy" indirection, no configuration object or environment variables, no new dependency.
3. The response pushes back on the speculative part of the ticket in a sentence (Redis "next year" is not built now) and marks the shortcut with a comment that names its ceiling and upgrade path (for example a single-process cache that would need Redis if the service scales out).
4. One small test or check for the cache behaviour is included or named explicitly.
