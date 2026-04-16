---
description: Execute a plan artifact phase by phase, pausing for human verification between phases
model: claude-opus-4-7
---

# Execute Plan

Implement an approved plan phase by phase. **Follow the plan's intent while adapting to reality.** Surface mismatches immediately rather than silently improvising.

**Default mode**: One phase at a time, pausing for human verification.
**Consecutive mode**: If the user says "run all phases" or "skip pauses", execute all phases but still stop at Verification Gates and run the final regression check.

## Execution Discipline

<investigate_before_answering>
Never modify a file you have not read in the current phase. Never claim an edit landed without verifying with a follow-up read or a `git diff`. If the plan references a file, read it FULLY before editing. If a tool result is unexpected, read the underlying file — do not speculate. Claude Opus 4.7 uses fewer tools by default than prior models; counter that default here by reading before every edit.
</investigate_before_answering>

<scope_discipline>
Implement only what the current phase's "Files to Change" section specifies. Do NOT:
- Add unrequested features, error handling, or defensive code
- Refactor surrounding code that the phase didn't call out
- Create new helper files or abstractions unless the plan explicitly requires them
- "Improve" code you didn't need to touch

If the plan code violates project standards, implement the correct version and note the deviation in your phase-completion report (per existing Rules).
</scope_discipline>

<destructive_action_safety>
Before any destructive or hard-to-reverse action, STOP and ask the user via `AskUserQuestion`. File edits and test runs are fine. Actions that require confirmation include:
- `git reset --hard`, `git push --force`, `git checkout .` (discards all), `git clean -fd`
- `rm -rf`, deleting files you didn't just create, dropping database tables
- Amending or rewriting published commits
- Any command that would modify the user's environment (package uninstalls, global config edits)

The Recovery section (Step 12) already reflects this for error paths — apply the same rule throughout execution, not just when things go wrong.
</destructive_action_safety>

## User-Provided Context

$ARGUMENTS

---

## Step 0: Check Arguments

If `$ARGUMENTS` is empty or contains only whitespace, present usage help (Form 1 in `_plans-config.md`) and stop:

```markdown
## `/execute-plan` — Implement an approved plan

Implements a plan phase by phase with verification pauses. Tracks progress via checkboxes and `state.json`, and recommends `/clear` + resume when context gets heavy.

**Usage:** `/execute-plan <plan-artifact-path>`

**Example:** `/execute-plan ~/.claude/.../plan-2026-04-08-auth-api.md`
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

Summarize to the user with a checkpoint banner (Form 3 in `_plans-config.md`):

```
─────────────────────────────────────────────
**Executing — <plan name>**

  Phase 1: <name> — <done | starting | pending>
  Phase 2: <name> — <done | starting | pending>
  Phase 3: <name> — <done | starting | pending>
  ...

  Starting from Phase <N>. Standards loaded: <list>.
```

Use plain words (`done`, `starting`, `pending`) for phase state — no glyphs.

---

## Step 4: Assess Context Before Each Phase

Before starting each phase (including the first), assess your context weight.

After completing 3+ phases in this session, emit the recommendation with the **exact resume command** prefilled (Form 7 advisory):

```markdown
## Context is getting heavy

Recommended: `/clear` this session, then resume with:

  `/execute-plan <full-plan-path>`

The plan's checkbox state (and `state.json`) preserves progress — I'll pick up exactly where I left off.
```

After completing 5+ phases in this session, escalate the language ("Strongly recommend") but emit the same exact-command banner. The user copies one line; they don't have to remember the path or the command shape.

Do NOT silently continue with degraded output quality. The plan's checkbox state and `state.json` are designed for exactly this purpose. Prefer `/clear` over `/compact` — a fresh context window eliminates rot, while compaction summarizes and still carries stale tokens.

---

## Step 5: Implement the Current Phase

Re-read the plan file from disk at the start of each phase — do NOT rely on memory of it.

Before starting implementation, display the phase-start marker (Form 4 in `_plans-config.md`):

```
── Phase <N> of <M> — <phase name> ──
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

## Step 7: Update Plan Checkboxes and State

Mark automated verification items as `- [x]` in the plan file. Do NOT check off manual items.

Then write/update a `state.json` file alongside the plan artifact (same directory, same basename with `.state.json` extension — e.g., `plan-2026-04-16-foo.md` → `plan-2026-04-16-foo.state.json`):

```json
{
  "plan_path": "<absolute path to plan.md>",
  "started_at": "<ISO 8601 timestamp from first phase start>",
  "last_updated": "<ISO 8601 timestamp, now>",
  "last_phase_completed": <integer, current phase number>,
  "total_phases": <integer>,
  "files_changed_this_session": ["<relative paths>"],
  "automated_checks_passed_this_phase": <true|false>,
  "manual_checks_confirmed": ["Phase 1", "Phase 2"],
  "resume_command": "/execute-plan <absolute plan path>"
}
```

If `state.json` already exists (resuming from a previous session), read it first and update in place — preserve `started_at` and extend arrays rather than overwriting.

This file is the machine-readable handoff. `/validate-plan` reads it first to understand what was actually run versus what the plan specified.

---

## Step 8: Pause for Human Verification (Default Mode Only)

If the plan contains a `### Verification Gate` at this point, this is a **mandatory stop** even in consecutive mode. Present the gate's criteria and wait for confirmation.

For regular phase boundaries in default mode, present a phase-complete banner (Form 5 in `_plans-config.md`):

```
**Phase <N> of <M> — <name> complete**

  Automated:
    ✓ <check 1>
    ✓ <check 2>

  Manual checks:
    - <manual check 1>
    - <manual check 2>
```

Use `✓` for passed automated checks and `✗` for failed ones. Manual checks are plain `-` bullets — they're a list, not a state. Then use `AskUserQuestion`:

- **Question**: "Phase [N] automated checks passed. Please verify the manual items above — how did it go?"
- **Options**: "All good" / "Found an issue" / "Stop here"

When the user chooses "Stop here", provide the exact resume command: `/execute-plan <artifact-path>`.

After confirmation, update manual checkboxes to `- [x]` in the plan file AND append the phase name to `manual_checks_confirmed` in `state.json`.

---

## Step 9: Repeat

Repeat Steps 4-8 for each remaining phase.

---

## Step 10: Regression Check

After all phases are complete, re-run ALL automated verification commands from ALL phases (not just the last one). Earlier phases can regress during later implementation.

Present results with a regression report (Form 5 style, grouped by phase):

```
**Regression check**

  Phase 1: <name>
    ✓ <check 1>
    ✓ <check 2>

  Phase 2: <name>
    ✓ <check 1>
    ✗ <check 2> — <brief error>

  Result: <N>/<M> checks passed.
```

Report any failures before presenting the final summary.

---

## Step 11: Final Summary

Present a completion banner (Form 6 in `_plans-config.md`):

```
─────────────────────────────────────────────
**Execution complete**

  <N> files changed.
  <N> phases completed.
  All automated checks passed.

  Next: review with `git diff`, then `/validate-plan <path>` or open a PR.
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
- Never edit a file without reading it in the current phase (see `<investigate_before_answering>`)
- Never take a destructive action without `AskUserQuestion` confirmation (see `<destructive_action_safety>`)
- Prefer `/clear` over `/compact` when recommending a context refresh

---

## Recovery

If execution goes wrong mid-phase and you need to start the phase over:

1. Check `git status` and `git diff` to see what changed
2. If changes should be discarded: suggest `git checkout -- <specific files>` for the files changed in this phase (never `git checkout .` — that discards ALL changes including completed phases)
3. Re-read the plan file to pick up from the current phase's start

If the user wants to undo a completed phase, suggest `git stash` to save current state, then `git diff <plan_commit>..HEAD` to review all changes.
