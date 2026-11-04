---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---
Ticket: "Sign-up accepts emails with capital letters and surrounding spaces, so the same person can register twice. Normalise the email in the sign-up handler before the uniqueness check."

Reply with the code change (changed or new lines per file) and a short note.

Existing files:

src/auth/signup.ts
```ts
import { users } from '../db';
export async function signUp(input: { email: string; password: string }) {
  const existing = await users.findByEmail(input.email);
  if (existing) throw new ConflictError('email taken');
  return users.create({ email: input.email, passwordHash: await hash(input.password) });
}
```

src/auth/login.ts
```ts
import { users } from '../db';
import { normalizeEmail } from './email';
export async function logIn(input: { email: string; password: string }) {
  const user = await users.findByEmail(normalizeEmail(input.email));
  ...
}
```

src/auth/email.ts
```ts
// Shared normalisation used by login and the password-reset flow; covered by email.test.ts.
export function normalizeEmail(raw: string): string {
  return raw.trim().toLowerCase();
}
```

Facts: `normalizeEmail` is exported, tested, and used by login and password reset; sign-up is the only auth entry point that does not call it.
