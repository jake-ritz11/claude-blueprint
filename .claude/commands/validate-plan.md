---
description: Validate that implementation matches the plan — run all checks and verify expected changes exist
model: opus
---

# Validate Plan

Post-execution validation: verify the implementation matches the plan's intent. Run all automated checks and verify expected code changes exist.

## User-Provided Context

$ARGUMENTS

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

Present results organized by phase:

- **Passing checks**: Automated verifications that succeeded
- **Failing checks**: Automated verifications that failed (with output)
- **Deviations**: Where implementation differs from plan (with severity: cosmetic / functional / missing)
- **Missing items**: Plan items that weren't implemented

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
