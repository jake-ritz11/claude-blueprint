---
type: plan
date: 2025-07-15
task: "Add user preferences API with persistent storage"
branch: feature/user-preferences
commit: a3f2c1d
ticket: PROJ-847
status: approved
research: ~/.claude/projects/-project-key/plans/research/research-2025-07-15-PROJ-847-user-preferences-api.md
---

# Plan: User Preferences API

## Overview

Add a user preferences API that allows authenticated users to store, retrieve, and update key-value preferences. Preferences are flat string key-value pairs with application-layer defaults. This follows the existing repository pattern and extends the user routes.

## Current State

- User routes exist at src/routes/users.ts with auth middleware
- Repository pattern established at src/repositories/user.repository.ts
- Database has `users` table, no preferences storage
- 3 existing migrations (users, roles, sessions)
- Zod validation schemas defined in src/validation/schemas.ts

## What We're NOT Doing

1. **No preference categories/namespacing** — Flat key-value pairs only. Namespacing adds query complexity without clear user demand. Can be added later as a non-breaking change.
2. **No JSON/complex value types** — String values only. Keeps the database schema simple and validation straightforward. Clients can JSON.stringify if they need structured data.
3. **No default preferences on user creation** — Defaults handled at the application layer in a config file. Avoids coupling user creation to preference definitions.
4. **No bulk import/export** — Individual get/put operations only. Bulk operations can be added if needed without changing the schema.
5. **No preference history/audit log** — Simple overwrite on update. History tracking is a separate concern.

---

## Phase 1: Database Migration & Model

### Overview
Create the `user_preferences` table and define the TypeScript model. This is first because all other phases depend on the database schema.

### Files to Change

**Create `src/db/migrations/004_create_user_preferences.ts`**
Migration with `up` and `down` functions following the pattern in `003_create_sessions.ts`. Table schema:
- `id` — SERIAL PRIMARY KEY
- `user_id` — INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT
- `key` — VARCHAR(255) NOT NULL
- `value` — TEXT NOT NULL
- `created_at` — TIMESTAMP DEFAULT NOW()
- `updated_at` — TIMESTAMP DEFAULT NOW()
- UNIQUE constraint on (user_id, key)

```sql
CREATE TABLE user_preferences (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  key VARCHAR(255) NOT NULL,
  value TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, key)
);
```

**Create `src/models/preference.model.ts`**
TypeScript interface following the pattern in `user.model.ts`:
```typescript
export interface UserPreference {
  id: number;
  userId: number;
  key: string;
  value: string;
  createdAt: Date;
  updatedAt: Date;
}
```

**Update `src/tests/setup.ts`**
Add `user_preferences` to the table truncation list at line 8.

### Automated Verification
- [ ] `npm run migrate` completes without errors
- [ ] `npm run migrate:rollback` successfully drops the table
- [ ] `npm run test` — existing tests still pass

### Manual Verification
- [ ] Inspect database — `user_preferences` table exists with correct schema
- [ ] Unique constraint works — inserting duplicate (user_id, key) fails

---

## Phase 2: Repository & Validation

### Overview
Create the preference repository and Zod validation schemas. This builds on the database schema from Phase 1 and provides the data access layer that routes will use.

### Files to Change

**Create `src/repositories/preference.repository.ts`**
Following the pattern in `user.repository.ts`:
- Constructor accepts `db` connection
- `findByUserId(userId: number)` — returns all preferences for a user
- `findByKey(userId: number, key: string)` — returns single preference or null
- `upsert(userId: number, key: string, value: string)` — insert or update using ON CONFLICT
- `delete(userId: number, key: string)` — delete single preference
- All queries use parameterized SQL

**Update `src/validation/schemas.ts`**
Add preference schemas following existing composition pattern:
```typescript
export const preferenceKeySchema = z.string().min(1).max(255).regex(/^[a-zA-Z0-9._-]+$/);
export const preferenceValueSchema = z.string().max(10000);
export const upsertPreferenceSchema = z.object({
  key: preferenceKeySchema,
  value: preferenceValueSchema,
});
```

### Automated Verification
- [ ] `npm run typecheck` passes
- [ ] `npm run test` — existing tests still pass

### Manual Verification
- [ ] Repository methods handle edge cases (nonexistent user, empty results)

---

## Phase 3: Routes & Tests

### Overview
Wire up the API endpoints and add comprehensive tests. This is last because it depends on both the database schema and repository from the previous phases.

### Files to Change

**Update `src/routes/users.ts`**
Add preference endpoints after existing user routes:
- `GET /api/users/:id/preferences` — list all preferences (returns `{ data: UserPreference[] }`)
- `GET /api/users/:id/preferences/:key` — get single preference (returns `{ data: UserPreference }` or 404)
- `PUT /api/users/:id/preferences/:key` — upsert preference (body: `{ value: string }`, returns `{ data: UserPreference }`)
- `DELETE /api/users/:id/preferences/:key` — delete preference (returns 204)

Each endpoint: auth middleware (already applied at router level), ownership check (`req.user.id === req.params.id`), Zod validation, then handler.

**Create `src/tests/routes/preferences.test.ts`**
Following test patterns in `users.test.ts`:
- Test auth requirement (401 without token)
- Test ownership check (403 accessing another user's preferences)
- Test CRUD operations (create, read, update, delete)
- Test validation (invalid key format, value too long)
- Test 404 for nonexistent preference
- Test default preference behavior (application-layer defaults)

**Create `src/config/defaults.ts` (update existing)**
Add default preference definitions:
```typescript
export const DEFAULT_PREFERENCES: Record<string, string> = {
  'ui.theme': 'light',
  'notifications.email': 'true',
  'locale': 'en-US',
};
```

### Automated Verification
- [ ] `npm run typecheck` passes
- [ ] `npm run test` — all tests pass including new preference tests
- [ ] `npm run lint` passes

### Manual Verification
- [ ] `curl` the endpoints manually — CRUD operations work
- [ ] Upsert behavior: PUT creates on first call, updates on second call
- [ ] Ownership check: user A cannot read/write user B's preferences

---

## Testing Strategy

- **Unit tests**: Repository methods tested with real test database (not mocks)
- **Integration tests**: Route tests using supertest against running Express app
- **Edge cases**: Empty preferences, max-length values, special characters in keys, concurrent upserts
- **Regression**: All existing user tests must continue to pass

## Standards Compliance

- `.ai/coding-standards.md` — TypeScript conventions, parameterized SQL
- `.ai/testing-standards.md` — Vitest patterns, test database setup
- `CONTRIBUTING.md` — PR format and review process

## References

- Research artifact: ~/.claude/projects/-project-key/plans/research/research-2025-07-15-PROJ-847-user-preferences-api.md
- Express router docs: https://expressjs.com/en/guide/routing.html
- Zod validation: https://zod.dev
