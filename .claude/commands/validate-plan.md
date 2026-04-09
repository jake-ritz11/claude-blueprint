---
description: Validate that implementation matches the plan — run all checks and verify expected changes exist
model: opus
---

# Validate Plan

Post-execution validation: verify the implementation matches the plan's intent. Run all automated checks and verify expected code changes exist.

## User-Provided Context

$ARGUMENTS

---

## Step 0: Check Arguments

If `$ARGUMENTS` is empty or contains only whitespace, present usage help following the Usage Help template from `_plans-config.md` and stop:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◇ Validate Plan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Usage: /validate-plan <plan-artifact-path>

Post-execution validation — runs all
automated checks from all phases, verifies
expected changes exist, reports deviations.

Example:
  /validate-plan ~/.claude/.../plan-2026-04-08-auth-api.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Do NOT proceed to Step 1. Return after showing usage.

---

## Step 1: Load the Plan

If `$ARGUMENTS` contains a file path, read the plan artifact FULLY. If no path provided, ask the user for one.

---

## Step 2: Run All Automated Verification

Collect every command from every phase's "Automated Verification" section. Run them ALL, regardless of checkbox state. Collect results (pass/fail with output for failures).

---

## Step 3: Verify Expected Changes

For each phase, check that the expected changes actually exist in the codebase:

- For each file listed in "Files to Change", verify the file exists and contains the expected modifications
- Use file:line references from the plan to spot-check key changes
- Note any deviations: files that weren't changed, changes that differ from the plan, unexpected additions

---

## Step 4: Compile Validation Report

Present results with a formatted report:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◆ Validation Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase 1: <name>
  ✓ Lint passed
  ✓ Tests passed
  ✓ All expected files exist

Phase 2: <name>
  ✓ Lint passed
  ✗ 2 test failures
  → file.spec.ts:45 — assertion error
  → file.spec.ts:78 — timeout

Overall: <N>/<M> checks passed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `✓` for passed checks, `✗` for failures, and `→` for details on failures. After the banner, list any deviations (with severity: cosmetic / functional / missing) and missing items.

---

## Step 5: Get User Decision

Use `AskUserQuestion`:

- **Question**: "Validation complete. [N] checks passed, [M] issues found. How to proceed?"
- **Options**:
  1. **"All validated"** — "Accept results and mark plan as validated"
  2. **"Fix issues"** — "Address the failing checks and deviations"
  3. **"Accept deviations"** — "Deviations are intentional — mark as validated with notes"

---

## Step 6: Update Plan Status

Update the plan artifact:

1. Set frontmatter `status: validated`
2. Append a `## Validation Results` section:

```markdown
## Validation Results

- **Date**: YYYY-MM-DD
- **Commit**: <short-hash>
- **Automated checks**: X/Y passed
- **Deviations**: [list any accepted deviations with rationale]
```

---

## Rules

- Run ALL automated checks, not just the ones from the last phase — regressions happen
- Do not auto-fix failures — report them and let the user decide
- Deviations from the plan aren't automatically wrong — the plan is a guide, not a contract
