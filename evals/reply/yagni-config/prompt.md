---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---
Ticket: "The carrier API sometimes answers 503 once and then works. Add a retry policy to the carrier client with exponential backoff, jitter, a configurable maximum number of attempts, and per-endpoint overrides via environment variables."

Reply with the code change (changed or new lines per file) and a short note.

Existing file; `ship` is the only carrier call in the codebase:

src/carrier/carrier-client.ts
```ts
export async function ship(payload: ShipRequest): Promise<ShipResponse> {
  const res = await fetch(CARRIER_URL + '/ship', { method: 'POST', body: JSON.stringify(payload) });
  if (!res.ok) throw new CarrierError(res.status, await res.text());
  return res.json();
}
```
Facts: production logs show the 503 happens about twice a day and never twice in a row; there is one endpoint; nobody has asked to tune anything at runtime.
