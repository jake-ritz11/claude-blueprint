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

## Step 0: Check Arguments

If `$ARGUMENTS` is empty or contains only whitespace, present usage help following the Usage Help template from `_plans-config.md` and stop:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◇ Execute Plan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Usage: /execute-plan <plan-artifact-path>

Implements an approved plan phase by
phase with verification pauses. Tracks
progress via checkboxes and recommends
context compaction after 3+ phases.

Example:
  /execute-plan ~/.claude/.../plan-2026-04-08-auth-api.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Do NOT proceed to Step 1. Return after showing usage.

---

## Step 1: Load the Plan

Read the plan file from `$ARGUMENTS` FULLY. If no path provided, ask for one.

---

## Step 2: Track Execution

Use `TodoWrite` to create one task per phase. Mark each complete after verification passes.

---

## Step 3: Orient

1. Check for existing `- [x]` checkmarks — pick up from the first unchecked item
2. Read files referenced in the plan, prioritized by modification order: files being changed first, then interface/contract files, then context files. **Cap at 8 files** — if the plan references more, read only the most critical ones and load others on-demand during each phase. Reading too many files upfront violates FIC and degrades output quality.
3. Read only the standards files relevant to the file types being modified in the current phase (not all standards files). Check `_plans-config.md` for the standards file mapping. If no mapping exists, read at most 2 standards files total.
4. Check for project knowledge docs and feature-specific gotchas
5. Scan the plan for completeness: check for any `TODO`, `TBD`, `FIXME`, `decide later`, or `open question` text. If found, warn the user: "The plan contains unresolved items: [list them]. These should be resolved via `/iterate-plan` before execution." Use `AskUserQuestion` to let them proceed or stop.
6. Compare the plan's frontmatter `commit` to current `git rev-parse --short HEAD`. If they differ, warn: "This plan was written at commit `{plan_commit}`, you're now at `{current_commit}` ({N} commits ahead). File references may be outdated."
7. Compare the plan's frontmatter `branch` to current `git branch --show-current`. If they differ, warn: "This plan was written on branch `{plan_branch}`, but you're on `{current_branch}`."

For either warning, use `AskUserQuestion`:
- **"Continue anyway"** — Proceed with execution
- **"View what changed"** — Run `git diff --stat {plan_commit}..HEAD` and present results, then re-ask
- **"Stop"** — End execution, provide resume command

Summarize to user with a formatted phase tracker:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ Executing: <plan name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ◇ Phase 1: <name>
  ◇ Phase 2: <name>
  ◇ Phase 3: <name>
  ...

Starting from Phase <N>. Standards loaded: <list>.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use ◆ for completed phases, ▶ for the starting phase, and ◇ for pending phases.

---

## Step 4: Assess Context Before Each Phase

Before starting each phase (including the first), assess your context weight.

After completing 3+ phases in this session, tell the user: "Context is getting heavy. I recommend running `/clear` and resuming with `/execute-plan <path>` — the checkbox state in the plan file lets me pick up exactly where I left off."

After completing 5+ phases in this session, escalate: "Context is very heavy — output quality is likely degraded. Strongly recommend `/clear` before continuing. The checkpoint state is saved and I will pick up exactly where I left off."

Do NOT silently continue with degraded output quality. The plan's checkbox state is designed for exactly this purpose.

---

## Step 5: Implement the Current Phase

Re-read the plan file from disk at the start of each phase — do NOT rely on memory of it.

Before starting implementation, display the Execution Progress banner from `_plans-config.md`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ Phase <N> of <M>: <phase name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Execute all changes listed. Follow code snippets faithfully. Apply all project coding standards.

**If reality doesn't match the plan**: STOP. Present what the plan expected vs. what actually exists (with file:line), explain impact, and wait for guidance.

---

## Step 6: Run Automated Verification

Run lint, tests, and any other commands from the phase's "Automated Verification" section. Fix issues and re-run.

**If a test failure persists after 2 fix attempts**, it may indicate a plan-level problem (wrong approach, missing dependency, broken assumption). STOP and present the failure to the user via `AskUserQuestion`:
- **"Keep trying"** — Continue debugging locally
- **"Iterate the plan"** — The plan needs revision. Provide the `/iterate-plan <path>` command
- **"Skip this check"** — Mark the check as failed and continue to the next phase

---

## Step 7: Update Plan Checkboxes

Mark automated verification items as `- [x]` in the plan file. Do NOT check off manual items.

---

## Step 8: Pause for Human Verification (Default Mode Only)

If the plan contains a `### Verification Gate` at this point, this is a **mandatory stop** even in consecutive mode. Present the gate's criteria and wait for confirmation.

For regular phase boundaries in default mode, present a phase completion banner following the Execution Progress template from `_plans-config.md`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◆ Phase <N> of <M>: <name> — Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Automated checks:
  ✓ <check 1>
  ✓ <check 2>

Manual checks needed:
  ◇ <manual check 1>
  ◇ <manual check 2>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `✓` for passed checks, `✗` for failed checks. Then use `AskUserQuestion`:

- **Question**: "Phase [N] automated checks passed. Please verify the manual items above — how did it go?"
- **Options**: "All good" / "Found an issue" / "Stop here"

When the user chooses "Stop here", provide the exact resume command: `/execute-plan <artifact-path>`.

After confirmation, update manual checkboxes to `- [x]` in the plan file.

---

## Step 9: Repeat

Repeat Steps 4-8 for each remaining phase.

---

## Step 10: Regression Check

After all phases are complete, re-run ALL automated verification commands from ALL phases (not just the last one). Earlier phases can regress during later implementation.

Present results with a formatted report:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ Regression Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase 1: <name>
  ✓ <check 1>
  ✓ <check 2>

Phase 2: <name>
  ✓ <check 1>
  ✗ <check 2> — <brief error>

Result: <N>/<M> checks passed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Report any failures before presenting the final summary.

---

## Step 11: Final Summary

Present a formatted completion banner:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◆ Execution Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  → <N> files changed
  → <N> phases completed
  → All automated checks passed

Next steps:
  → Review changes with `git diff`
  → Create PR or validate with /validate-plan <path>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then list all files changed with summaries. Note any non-obvious behaviors worth documenting in project knowledge files.

To validate implementation against the plan, run `/validate-plan <path>`.

---

## Rules

- Never implement Phase N+1 before Phase N is confirmed
- If plan code violates project standards, implement the correct version and note the deviation
- No improvisation — surface mismatches, don't silently fix them
- At the start of each phase, always re-read the plan file from disk — do NOT rely on memory of it
- Verification Gates in the plan are mandatory stops, even in consecutive mode

---

## Recovery

If execution goes wrong mid-phase and you need to start the phase over:

1. Check `git status` and `git diff` to see what changed
2. If changes should be discarded: suggest `git checkout -- <specific files>` for the files changed in this phase (never `git checkout .` — that discards ALL changes including completed phases)
3. Re-read the plan file to pick up from the current phase's start

If the user wants to undo a completed phase, suggest `git stash` to save current state, then `git diff <plan_commit>..HEAD` to review all changes.
