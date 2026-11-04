---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---
Ticket: "Rename the config key `feed.refreshMinutes` to `feed.refreshIntervalMinutes` in the loader and its default. Nothing else is in scope; the key is read nowhere else."

Reply with the code change (changed or new lines per file) and a short note.

Existing file:

src/config/load-feed-config.ts
```ts
import { readFileSync } from 'fs';
import { parse } from 'yaml';
import { Logger } from '../log'; // TODO: unused since the move to structured logs

export interface FeedConfig { refreshMinutes: number; url: string }

export function loadFeedConfig(path: string): FeedConfig {
  const raw = parse(readFileSync(path, 'utf8'));
  return {
    refreshMinutes: raw?.feed?.refreshMinutes ?? 30,
    url: raw?.feed?.url,
  };
}

export function isStale(lastRun: Date, cfg: FeedConfig): boolean {
  return Date.now() - lastRun.getTime() > cfg.refreshMinutes * 60000;
}
```

Facts: `Logger` is imported and unused; `url` can be undefined at runtime although the type says string; neither is part of the ticket.
