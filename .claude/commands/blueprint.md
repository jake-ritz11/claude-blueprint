---
description: Full research > plan > execute workflow in one command, with human verification between phases
model: claude-opus-4-7
---

# Blueprint

End-to-end task execution: Research > Plan > Execute. Each phase writes an artifact and pauses for your review.

## Methodology

This workflow uses **Frequent Intentional Compaction (FIC)** — each phase runs with minimal context, produces a tight artifact (~200 lines), and hands off to the next phase. The artifacts are the product, not the conversation.

Review artifacts at checkpoints — that's where errors are cheapest to catch. A flawed research artifact compounds into a flawed plan, which compounds into flawed code. Catching it early saves everything downstream.

## User-Provided Context

$ARGUMENTS

---

## Step 0: Check Arguments

If `$ARGUMENTS` is empty or contains only whitespace, present usage help (Form 1 in `_plans-config.md`) and stop:

```markdown
## `/blueprint` — Full research > plan > execute pipeline

Runs research, plan, and execute back to back with human verification between phases.

**Usage:** `/blueprint <task description>`

**Example:** `/blueprint Add user preferences API`
```

Do NOT proceed. Return after showing usage.

---

## Step 0.5: Task Specification Intake

A well-specified task up front produces better research, better plans, and fewer revisions. Bundle the intake into a single `AskUserQuestion` call before anything else.

**Skip heuristic**: If `$ARGUMENTS` already looks pre-specified — contains newlines, exceeds ~200 characters, or explicitly says "run all phases" / "skip intake" — skip this step and pass `$ARGUMENTS` through as-is. This preserves the one-shot flow for advanced users.

Otherwise, use `AskUserQuestion` with these 4 bundled questions:

1. **Intent** — "What does 'done' look like for this task?"
   - Options: "Feature working end-to-end" / "Bug fixed + regression test" / "Refactor with no behavior change" / "Other (describe)"
2. **Scope constraint** — "What is explicitly OUT of scope?"
   - Options: "Keep it surgical (no refactors)" / "Allow related cleanup" / "Full refactor welcome" / "Other (specify)"
3. **Key files or areas** — "Are there specific files, modules, or areas to focus on?"
   - Options: "No preference (let research find it)" / "I'll specify in Other" — free text via "Other"
4. **Acceptance check** — "How will you verify this works?"
   - Options: "Existing tests pass" / "New tests I'll write" / "Manual verification" / "Other"

Compose the answers into a well-formed task spec (multi-line) and use that as the task description passed to Phase 1. The spec replaces `$ARGUMENTS` for all downstream sub-commands.

Example composed spec:

```
Task: <original $ARGUMENTS>

Intent: <answer 1>
Out of scope: <answer 2>
Focus areas: <answer 3>
Acceptance: <answer 4>
```

---

## Step 0.6: Environment Check

Quickly verify the workspace is in a sane state before burning context on research.

1. Run `git branch --show-current` and `git status --short` in a single parallel bash call.
2. If the current branch is `main` or `master` AND there are uncommitted modifications, use `AskUserQuestion`:
   - **Question**: "You're on `{branch}` with uncommitted changes. Create a feature branch first?"
   - **Options**:
     1. **"Create branch now"** — Suggest a kebab-case branch name derived from the task spec and run `git checkout -b <suggested-name>`
     2. **"Stay on current branch"** — Proceed (flag as risky in the session banner)
     3. **"I'll handle it"** — Stop; tell the user to re-run `/blueprint` once their branch is ready
3. Parse a ticket ID from the branch name if present (e.g., `PROJ-1234-foo-bar` → `PROJ-1234`). Surface it in the session banner so the user doesn't have to repeat it.
4. Display the environment result in the Session Setup banner (below).

---

## Step 0.7: Session Setup Advisory

Emit a one-time informational section (Form 7 in `_plans-config.md`). This is NOT blocking — do not prompt the user. It surfaces harness-level settings the user may not know about so they can adjust before the long run starts.

```markdown
## Session setup

**Environment**
- Branch: `<current-branch>` (ticket: `<ticket-id-or-none>`)
- Status: <clean | N modified files>

**For best results**
- **Model:** `claude-opus-4-7` (pinned in frontmatter)
- **Effort:** `xhigh` recommended (or `high` for budget work). Adjust via `/model` or your harness settings.
- **Mode:** After plan approval, Shift+Tab enables auto mode for trusted tasks — reduces turns.
- **Alerts:** Set task-completion notifications if your harness supports them; long-running phases benefit.

Proceeding to research.
```

Show this section exactly once per `/blueprint` invocation, not between sub-commands.

---

## Workflow

Display the initial phase tracker (Form 2 in `_plans-config.md`):

```
Task: <$ARGUMENTS summary>
Progress: Research starting. Plan and Execute pending.
```

Then proceed through the three phases below.

---

## Phase 1: Research

Read `.claude/commands/research.md` FULLY, then follow every step exactly. Pass the composed task spec from Step 0.5 (or raw `$ARGUMENTS` if intake was skipped) as the task description. Skip Step 0 (arguments are already validated). The sub-command's `AskUserQuestion` checkpoint handles the proceed/revise/stop decision.

**After this phase**: Prefer `/clear` over `/compact` — the research artifact path is all that needs to carry forward, and a fresh context window eliminates rot entirely. Emit the exact resume command so the user only has to paste one line:

```
To continue with a fresh context (recommended):
  1. Run /clear
  2. Paste: /plan <full-research-artifact-path>
```

**Transition**: Before starting Phase 2, display:

```
Progress: Research done. Plan starting. Execute pending.
```

---

## Phase 2: Planning

Read `.claude/commands/plan.md` FULLY, then follow every step exactly. Pass the research artifact path — skip Step 0 and the "no path provided" prompt. The sub-command's checkpoints handle design options, phase buy-in, and final review.

**After this phase**: Prefer `/clear` over `/compact` — the plan artifact path is all that needs to carry forward, and a fresh context window eliminates rot entirely. Emit the exact resume command:

```
To continue with a fresh context (recommended):
  1. Run /clear
  2. Paste: /execute-plan <full-plan-artifact-path>
```

**Transition**: Before starting Phase 3, display:

```
Progress: Research done. Plan done. Execute starting.
```

---

## Phase 3: Execute

Read `.claude/commands/execute-plan.md` FULLY, then follow every step exactly. Pass the plan artifact path — skip Step 0 and the "no path provided" prompt.

Default mode (phase-by-phase with pauses) unless the user said "run all phases" or "skip pauses".

**After execution**: Do NOT emit a separate "Blueprint complete" banner. `/execute-plan`'s Step 11 "Execution complete" banner (Form 6) already carries the closing moment — adding a second Form 6 banner here duplicates the weight and the content. Let execution's own completion stand.

---

## Rules

- Sub-command files are the source of truth — follow them completely, don't abbreviate
- Checkpoints between phases are not optional
- If the user says "stop", always provide the exact command to resume from where they left off
- Between phases, prefer `/clear` over `/compact` — the artifact path carries all state, and a fresh window beats a compressed one
- Always display the phase tracker banners at transitions
- Intake (Step 0.5) is skipped for pre-specified inputs (multi-line or >~200 chars); don't re-prompt users who already specified their task

## Resuming

If stopped at any checkpoint, resume with the artifact path:

- **Restart research**: `/research <task description>`
- **Resume at planning**: `/plan <research-artifact-path>`
- **Resume at execution**: `/execute-plan <plan-artifact-path>`

The artifact paths encode all state needed to continue. Checkbox state in plan files tracks execution progress.
