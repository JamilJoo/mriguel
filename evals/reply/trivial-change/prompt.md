---
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---
Ticket: "Change the default catalogue page size from 20 to 24 so the grid shows full rows of four."

Reply with the code change (changed or new lines per file) and a short note.

Existing file:

src/catalogue/paging.ts
```ts
export const DEFAULT_PAGE_SIZE = 20;
export const MAX_PAGE_SIZE = 96;

export function pageSize(requested?: number): number {
  if (!requested || requested < 1) return DEFAULT_PAGE_SIZE;
  return Math.min(requested, MAX_PAGE_SIZE);
}
```

Facts: the constant is read only through `pageSize`; the repository keeps no tests for this file; the grid is four cards wide on every breakpoint.
