---
description: Execute a plan artifact phase by phase, pausing for human verification between phases
model: opus
---

# Execute Plan

Implement an approved plan phase by phase. **Follow the plan's intent while adapting to reality.** Surface mismatches immediately rather than silently improvising.

**Default mode**: One phase at a time, pausing for human verification.
**Consecutive mode**: If the user says "run all phases" or "skip pauses", execute all phases but still run verification at the end.

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

## Step 4: Implement the Current Phase

Execute all changes listed. Follow code snippets faithfully. Apply all project coding standards.

**If reality doesn't match the plan**: STOP. Present what the plan expected vs. what actually exists (with file:line), explain impact, and wait for guidance.

---

## Step 5: Run Automated Verification

Run lint, tests, and any other commands from the phase's "Automated Verification" section. Fix all issues to zero errors before proceeding.

---

## Step 6: Update Plan Checkboxes

Mark automated verification items as `- [x]` in the plan file. Do NOT check off manual items.

---

## Step 7: Pause for Human Verification (Default Mode Only)

Present automated checks that passed and manual checks needed, then use `AskUserQuestion`:

- **Question**: "Phase [N] automated checks passed. Please verify the manual items above — how did it go?"
- **Options**: "All good" / "Found an issue" / "Stop here"

After confirmation, update manual checkboxes to `- [x]` in the plan file.

---

## Step 8: Repeat

Repeat Steps 4-7 for each remaining phase.

---

## Step 9: Final Summary

Present: all files changed with summaries, then suggest next steps (review changes, create PR, etc.). Note any non-obvious behaviors worth documenting in project knowledge files.

---

## Rules

- Never implement Phase N+1 before Phase N is confirmed
- If plan code violates project standards, implement the correct version and note the deviation
- No improvisation — surface mismatches, don't silently fix them
- If context gets long, re-read the plan file rather than relying on memory
