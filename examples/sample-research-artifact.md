---
type: research
date: 2025-07-15
task: "Add user preferences API with persistent storage"
branch: feature/user-preferences
commit: a3f2c1d
ticket: PROJ-847
status: reviewed
---

# Research: User Preferences API

## Research Question

What infrastructure exists for adding a user preferences API that allows users to store and retrieve key-value preferences with type validation and default values?

## Summary

The codebase has an established REST API pattern using Express routers with Zod validation, a PostgreSQL database accessed through a repository pattern, and comprehensive test coverage using Vitest. User-related endpoints already exist in `src/routes/users.ts` with authentication middleware. The database has a `users` table but no preferences storage — a new `user_preferences` table is needed. The existing pattern for adding new entities (migration → model → repository → route → tests) is well-established and consistent across the codebase.

## Relevant Files

| File | Lines | Purpose |
|------|-------|---------|
| src/routes/users.ts | 1-89 | Existing user endpoints — follows router pattern to extend |
| src/routes/index.ts | 1-34 | Route registration — where new router gets mounted |
| src/middleware/auth.ts | 12-45 | Auth middleware — applied to all /users routes |
| src/repositories/user.repository.ts | 1-67 | User repo — pattern to follow for preferences repo |
| src/models/user.model.ts | 1-28 | User model — schema definition pattern |
| src/db/migrations/003_create_sessions.ts | 1-32 | Most recent migration — naming convention reference |
| src/validation/schemas.ts | 1-156 | Zod schemas — existing validation patterns |
| src/tests/routes/users.test.ts | 1-203 | User route tests — test patterns and mock setup |
| src/config/defaults.ts | 1-45 | App defaults — where preference defaults could live |

## Existing Patterns to Follow

### 1. Repository Pattern
- Location: src/repositories/user.repository.ts:8-15
- Each entity has a repository class with `findById`, `findAll`, `create`, `update`, `delete` methods
- Repositories accept a `db` connection in the constructor (dependency injection)
- All queries use parameterized SQL via `pg` library, no ORM

### 2. Route Definition Pattern
- Location: src/routes/users.ts:5-12
- Routes use `express.Router()` with method chaining
- Each route has Zod validation middleware before the handler
- Response format: `{ data: T }` for success, `{ error: string, details?: unknown }` for errors
- Auth middleware applied at the router level, not per-route

### 3. Migration Pattern
- Location: src/db/migrations/003_create_sessions.ts:1-32
- Migrations export `up` and `down` functions
- Sequential numbering with descriptive names: `004_create_user_preferences.ts`
- Uses raw SQL in `db.query()` calls, not a migration framework

### 4. Validation Pattern
- Location: src/validation/schemas.ts:89-112
- Zod schemas defined per-entity, exported as named constants
- Request body, query params, and path params each have separate schemas
- Reusable base schemas composed with `.extend()` and `.pick()`

## Data Flow

### Current User Request Flow
1. **Entry**: `POST /api/users/:id/...` → src/routes/index.ts:18 (mounts user router)
2. **Auth**: src/middleware/auth.ts:12 → validates JWT, attaches `req.user`
3. **Validation**: Zod schema middleware → src/validation/schemas.ts
4. **Handler**: Route handler in src/routes/users.ts → calls repository
5. **Repository**: src/repositories/user.repository.ts → parameterized SQL query
6. **Response**: `{ data: result }` with appropriate HTTP status

### Proposed Preferences Flow (Same Pattern)
1. **Entry**: `GET/PUT /api/users/:id/preferences` → new route in users.ts or separate router
2. **Auth**: Same auth middleware (user can only access own preferences)
3. **Validation**: New Zod schemas for preference key-value pairs
4. **Handler**: New preference handlers → calls preference repository
5. **Repository**: New preference repository → queries `user_preferences` table
6. **Response**: Same response format

## Constraints & Gotchas

1. **Auth middleware ownership check**: src/middleware/auth.ts:38 — The existing middleware only verifies the JWT is valid. It does NOT check that `req.user.id === req.params.id`. Routes currently handle this check individually. The preferences endpoint needs the same ownership check.

2. **Migration ordering**: src/db/migrations/ — Migrations must be numbered sequentially. Current latest is `003`. The new migration must be `004`.

3. **No cascading deletes**: src/db/migrations/001_create_users.ts:18 — The `users` table uses `ON DELETE RESTRICT`. The preferences table foreign key needs to match this convention OR explicitly handle user deletion.

4. **Response envelope format**: src/routes/users.ts:24 — All endpoints wrap responses in `{ data: T }`. The preferences endpoint must follow this, not return raw arrays or objects.

5. **Test database setup**: src/tests/setup.ts:5-12 — Tests use a separate `test` database with migrations run before the suite. New migrations are automatically picked up, but the test setup truncates tables between tests — the new table needs to be added to the truncation list at src/tests/setup.ts:8.

## Open Questions

1. **Preference value types**: Should preferences support only strings, or also numbers/booleans/JSON? This affects the database column type and validation schemas.
2. **Default preferences**: Should there be a set of default preferences created when a user signs up, or should defaults be handled at the application layer (return defaults when no preference exists)?
3. **Preference namespacing**: Should preferences be flat key-value pairs, or grouped by category (e.g., `notifications.email`, `ui.theme`)?

## Code References

- Route registration: src/routes/index.ts:18
- Auth middleware: src/middleware/auth.ts:12-45
- Ownership check pattern: src/routes/users.ts:28-31
- Repository constructor injection: src/repositories/user.repository.ts:8-10
- Zod schema composition: src/validation/schemas.ts:89-112
- Migration up/down pattern: src/db/migrations/003_create_sessions.ts:3-28
- Test truncation list: src/tests/setup.ts:8
- Response envelope: src/routes/users.ts:24
- Error response format: src/routes/users.ts:42-44
