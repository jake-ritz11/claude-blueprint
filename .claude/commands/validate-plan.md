---
description: Validate that implementation matches the plan — run all checks and verify expected changes exist
model: claude-opus-4-7
---

# Validate Plan

Post-execution validation: verify the implementation matches the plan's intent. Run all automated checks and verify expected code changes exist.

## User-Provided Context

$ARGUMENTS

---

## Step 0: Check Arguments

If `$ARGUMENTS` is empty or contains only whitespace, present usage help (Form 1 in `_plans-config.md`) and stop:

```markdown
## `/validate-plan` — Validate implementation against a plan

Post-execution validation — runs all automated checks from all phases, verifies expected changes exist, and reports deviations.

**Usage:** `/validate-plan <plan-artifact-path>`

**Example:** `/validate-plan ~/.claude/.../plan-2026-04-08-auth-api.md`
```

Do NOT proceed to Step 1. Return after showing usage.

---

## Step 1: Load the Plan and State

If `$ARGUMENTS` contains a file path, read the plan artifact FULLY. If no path provided, ask the user for one.

Then look for a sibling `state.json` file (same directory, basename with `.state.json` extension). If found, read it — it records what `/execute-plan` actually ran: phases completed, files changed, automated check results per phase, manual checks confirmed. Use this to distinguish "validation against the plan" from "validation of what was executed" when they differ.

If no `state.json` exists, note it in the report — this plan was either implemented manually or with an older execute-plan version, and validation will rely entirely on checkbox marks and code inspection.

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

Present results with a validation report (Form 5 style, grouped by phase):

```
**Validation report**

  Phase 1: <name>
    ✓ Lint passed
    ✓ Tests passed
    ✓ All expected files exist

  Phase 2: <name>
    ✓ Lint passed
    ✗ 2 test failures
      - file.spec.ts:45 — assertion error
      - file.spec.ts:78 — timeout

  Result: <N>/<M> checks passed.
```

Use `✓` for passed checks and `✗` for failures. Nest failure details as plain `-` bullets under the failing check. After the report, list any deviations (with severity: cosmetic / functional / missing) and missing items.

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
- Validate against the plan as written; do NOT propose new work or additional validation steps beyond what the plan specifies. Failed checks get reported, not "fixed on the side."
