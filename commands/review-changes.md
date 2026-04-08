# Review Changes

Review code changes against project standards before creating a PR. Catches issues locally before expensive CI runs.

## User-Provided Context

$ARGUMENTS

## Mode Detection

Check if the user requested quick mode:

- If `$ARGUMENTS` contains "quick", "fast", or "quick check" > **Quick Mode**
- Otherwise > **Full Mode** (default)

**Quick Mode** skips:

- Phase 1 (automated validation tools)
- Phase 4 (test coverage check)

---

## Phase 1: Automated Validation (Full Mode Only)

Skip this phase if in Quick Mode.

Run your project's validation tools in parallel. Examples:

```bash
# Lint + format
<your-lint-command>

# Dependency checks (if applicable)
<your-dep-check-command>

# Type checking
<your-typecheck-command>
```

> **Customize**: Replace with your project's actual lint, format, type-check, and dependency validation commands.

If any validation fails:

1. Report the specific failures
2. Ask: "Would you like me to attempt auto-fixes?"
3. If user agrees, run the auto-fix and report results
4. Continue to Phase 2 regardless (validation issues will also be caught in review)

---

## Phase 2: Determine Scope

### Step 1: Detect Base Branch

Determine the base branch — check for a configured default or fall back to `main`.

### Step 2: Confirm with User

**IMPORTANT:** The base branch detection is a best guess. Git has no foolproof way to determine this.

Ask the user: "Detected base branch: `origin/$BASE_BRANCH`. Is this correct?"

Options:

- Yes, continue
- No, let me specify (then ask for the correct branch name)

### Step 3: Find Changed Files

Use `git cherry` to find only local commits (avoids noise from merged branches):

```bash
# Get commits unique to this branch (marked with + prefix)
LOCAL_COMMITS=$(git cherry -v origin/$BASE_BRANCH | grep '^+' | cut -d' ' -f2)

# Get changed files from those specific commits
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r $LOCAL_COMMITS | sort -u)
```

If no local commits found, fall back to:

```bash
CHANGED_FILES=$(git diff --name-only origin/$BASE_BRANCH...HEAD)
```

### Step 4: Classify Files

For each changed file, determine:

1. **Status**:
   - `NEW` - File doesn't exist in base branch
   - `MOVED` - Check `git diff --find-renames` for rename detection
   - `MODIFIED` - File exists in base and has changes

2. **Type** (for agent assignment):
   - Group files by their type/purpose (e.g., components, services, tests, styles, configs)

Display the classification to the user.

---

## Phase 3: Standards Review (Parallel Specialist Agents)

Spawn specialist agents in parallel based on file types present. Each agent should:

1. Read the relevant standards files for its file type
2. Review the files assigned to it
3. Be **strict with NEW files** (all standards apply) and **lenient with MODIFIED files** (only flag changed lines)
4. Return findings with file:line references and severity levels

> **Customize**: Define which specialist agents to spawn based on your project's tech stack. Examples:
>
> - **Frontend agent**: Components, templates, styles
> - **Backend agent**: Services, APIs, data access
> - **Test agent**: Test files, test utilities
> - **Style agent**: CSS/SCSS files

---

## Phase 4: Test Coverage Check (Full Mode Only)

Skip this phase if in Quick Mode.

For each NEW or MODIFIED source file (not test files), check if a corresponding test file exists. Flag missing tests as **REQUIRED** (not just a warning).

```
## Test Coverage

[check] component.ts > component.test.ts
[missing] service.ts > No test file found [REQUIRED]
```

---

## Phase 5: Report

Aggregate results from all specialist agents into a unified report:

```markdown
## Code Review Summary

**Files reviewed:** X
**Issues found:** Y CRITICAL, Z REQUIRED, W OPTIONAL

### Phase 1 Validation Results

- Lint: PASS/FAIL
- Type check: PASS/FAIL
- Dependencies: PASS/FAIL

### Critical Issues (Must Fix)

1. src/file.ts:42 - Description

### Required Changes (New Files Only)

1. src/new-file.ts:15 - Description

### Missing Test Coverage

1. src/service.ts - No test file

### Optional Improvements

1. src/existing-file.ts:30 - Consider using modern pattern

### Positive Observations

- Good use of [pattern] in [file]
```

---

## Phase 6: Post-Review Prompt

List specific fixes that can be applied:

```markdown
## Fixes Available

**Auto-fixable** (lint --fix):

- src/foo.ts: 3 lint issues
- src/bar.ts: 2 formatting issues

**Manual fixes needed:**

- src/foo.ts:42 - Description of manual change
- src/service.ts - Create test file
```

Ask the user: "Would you like me to apply the auto-fixes?"

If yes:

1. Run your project's auto-fix command
2. Report results
3. Show remaining manual fixes

---

## Notes

- **Local review is faster than CI** — catches issues before push
- **Quick mode** for rapid iteration when you just want standards feedback
- **Full mode** for thorough pre-PR review
