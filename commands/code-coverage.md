---
description: Analyze branch changes and generate unit tests for high code coverage via the blueprint workflow
model: opus
---

# Code Coverage

Analyze what changed on this branch, identify coverage gaps, and use the blueprint workflow to write tests.

## User-Provided Context

$ARGUMENTS

---

## Phase 0: Analyze Branch Changes

### Step 1: Determine the base branch

- If `$ARGUMENTS` provides a base branch, use it. Otherwise default to `main`.
- Run `git fetch origin <base>`

### Step 2: Get the diff

- `git log origin/<base>..HEAD --oneline --first-parent --no-merges`
- `git diff origin/<base>...HEAD --name-only` to list changed files
- `git diff origin/<base>...HEAD` for the full diff

### Step 3: Identify coverage targets

From the changed files, filter to only source files that need test coverage:

- **Include**: Files with logic — components, services, utilities, etc.
- **Exclude**: Test files, config files, type/interface-only files, barrel/index files, documentation
- For each included file, check if a corresponding test file exists (sibling or in same directory)

> **Customize**: Adapt the include/exclude patterns to match your project's file conventions.

### Step 4: Run coverage on changed files

Run your project's test runner with coverage enabled, scoped to only the directories containing changed source files.

> **Customize**: Replace with your project's coverage command. Examples:
>
> ```bash
> # Vitest
> cd project && pnpm run test --coverage --include src/path/to/changed/
>
> # Jest
> npx jest --coverage --collectCoverageFrom='src/path/**/*.ts' src/path/
>
> # pytest
> pytest --cov=src/path tests/path/
> ```

### Step 5: Parse coverage report

Read the coverage report (lcov, JSON, or text — whatever your runner produces).

LCOV format reference:

- `SF:<filepath>` — source file path
- `DA:<line>,<hits>` — line execution data (hits=0 means uncovered)
- `BRDA:<line>,<block>,<branch>,<hits>` — branch data (hits=0 means uncovered)
- `LF:<count>` — total lines found
- `LH:<count>` — total lines hit
- `end_of_record` — end of file record

For each coverage target file from Step 3:

1. Find its entry in the coverage report
2. Extract uncovered lines and branches
3. Cross-reference uncovered lines with the git diff to identify which **new/changed** lines lack coverage
4. Skip files that are already at 100% coverage on new code

### Step 6: Catalog coverage gaps

For each file with coverage gaps on new/changed code:

1. Read the source file at the uncovered line numbers
2. Identify the methods/functions/branches that are uncovered
3. Note whether the gap is a missing line (logic not executed) or missing branch (condition not tested)
4. Skip trivial gaps (imports, type declarations, unreachable framework code)

### Step 7: Build the coverage report

Output a structured summary:

```
## Coverage Analysis (from actual coverage data)

### Files with coverage gaps on new code
- `path/to/file.ts` (current: XX%) — [specific uncovered methods/branches with line numbers]

### Files with full coverage on new code
- `path/to/file.ts` (100% on new code) — no action needed

### Files needing new test files
- `path/to/file.ts` — no existing test file found

### Summary
- X files changed with logic
- Y files have coverage gaps on new/changed code
- Z uncovered lines, W uncovered branches total
```

Present this report to the user via `AskUserQuestion`:

- **"Proceed to blueprint"** — Start the research > plan > execute workflow for these coverage targets
- **"Adjust scope"** — Let the user include/exclude specific files before proceeding
- **"Stop here"** — End with just the analysis

---

## Phase 1-3: Blueprint Workflow

Read `.claude/commands/blueprint.md` FULLY, then follow every step exactly.

Pass the following as context to the blueprint (in place of `$ARGUMENTS`):

> **Task**: Write unit tests to achieve high code coverage for all branch changes identified in the coverage analysis above.
>
> **Coverage targets**: [insert the coverage report from Step 7, including specific uncovered line numbers and branch conditions]
>
> **Requirements**:
>
> - Follow your project's testing standards strictly
> - Read 1-2 existing test files in the same directory as each target to match patterns
> - Target the specific uncovered lines and branches from the coverage report — do not guess what needs coverage
> - Test edge cases, error paths, and boundary conditions — not just happy paths
> - After writing tests, re-run with coverage to verify gaps are closed
> - Run tests after writing to confirm they pass

---

## Rules

- Phase 0 analysis MUST complete before entering the blueprint workflow
- The blueprint sub-commands (research, plan, execute) are the source of truth — follow them completely
- Scope is **branch changes only** — do not attempt to cover pre-existing uncovered code
- Skip trivial changes that don't warrant tests (import reordering, type-only files, comments)
- All checkpoints between blueprint phases are mandatory
