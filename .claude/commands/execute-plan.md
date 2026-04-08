---
description: Execute a plan artifact phase by phase, pausing for human verification between phases
model: opus
---

# Execute Plan

Implement an approved plan phase by phase. **Follow the plan's intent while adapting to reality.** Surface mismatches immediately rather than silently improvising.

**Default mode**: One phase at a time, pausing for human verification.
**Consecutive mode**: If the user says "run all phases" or "skip pauses", execute all phases but still stop at Verification Gates and run the final regression check.

## User-Provided Context

$ARGUMENTS

---

## Step 1: Load the Plan

Read the plan file from `$ARGUMENTS` FULLY. If no path provided, ask for one.

---

## Step 2: Track Execution

Use `TodoWrite` to create one task per phase. Mark each complete after verification passes.

---

## Step 3: Orient

1. Check for existing `- [x]` checkmarks — pick up from the first unchecked item
2. Read ALL files referenced in the plan FULLY
3. Read relevant standards files for the file types being modified
4. Check for project knowledge docs and feature-specific gotchas

Summarize to user: plan name, phases total/completed, starting phase, standards loaded.

---

## Step 4: Assess Context Before Each Phase

Before starting each phase (including the first), assess your context weight.

After completing 3+ phases in this session, tell the user: "Context is getting heavy. I recommend running `/clear` and resuming with `/execute-plan <path>` — the checkbox state in the plan file lets me pick up exactly where I left off."

Do NOT silently continue with degraded output quality. The plan's checkbox state is designed for exactly this purpose.

---

## Step 5: Implement the Current Phase

Re-read the plan file from disk at the start of each phase — do NOT rely on memory of it.

Execute all changes listed. Follow code snippets faithfully. Apply all project coding standards.

**If reality doesn't match the plan**: STOP. Present what the plan expected vs. what actually exists (with file:line), explain impact, and wait for guidance.

---

## Step 6: Run Automated Verification

Run lint, tests, and any other commands from the phase's "Automated Verification" section. Fix all issues to zero errors before proceeding.

---

## Step 7: Update Plan Checkboxes

Mark automated verification items as `- [x]` in the plan file. Do NOT check off manual items.

---

## Step 8: Pause for Human Verification (Default Mode Only)

If the plan contains a `### Verification Gate` at this point, this is a **mandatory stop** even in consecutive mode. Present the gate's criteria and wait for confirmation.

For regular phase boundaries in default mode: present automated checks that passed and manual checks needed, then use `AskUserQuestion`:

- **Question**: "Phase [N] automated checks passed. Please verify the manual items above — how did it go?"
- **Options**: "All good" / "Found an issue" / "Stop here"

After confirmation, update manual checkboxes to `- [x]` in the plan file.

---

## Step 9: Repeat

Repeat Steps 4-8 for each remaining phase.

---

## Step 10: Regression Check

After all phases are complete, re-run ALL automated verification commands from ALL phases (not just the last one). Earlier phases can regress during later implementation. Report any failures before presenting the final summary.

---

## Step 11: Final Summary

Present: all files changed with summaries, then suggest next steps (review changes, create PR, etc.). Note any non-obvious behaviors worth documenting in project knowledge files.

To validate implementation against the plan, run `/validate-plan <path>`.

---

## Rules

- Never implement Phase N+1 before Phase N is confirmed
- If plan code violates project standards, implement the correct version and note the deviation
- No improvisation — surface mismatches, don't silently fix them
- At the start of each phase, always re-read the plan file from disk — do NOT rely on memory of it
- Verification Gates in the plan are mandatory stops, even in consecutive mode
