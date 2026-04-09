---
description: Full research > plan > execute workflow in one command, with human verification between phases
model: opus
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

If `$ARGUMENTS` is empty or contains only whitespace, present usage help following the Usage Help template from `_plans-config.md` and stop:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◇ Blueprint
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Usage: /blueprint <task description>

Full research > plan > execute pipeline
with human verification between phases.

Example:
  /blueprint Add user preferences API
  /blueprint Fix auth middleware timeout
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Do NOT proceed. Return after showing usage.

---

## Workflow

Display the initial phase tracker:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◆ Blueprint
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ▶ Research     starting
  ◇ Plan         pending
  ◇ Execute      pending

Task: <$ARGUMENTS summary>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then proceed through the three phases below.

---

## Phase 1: Research

Read `.claude/commands/research.md` FULLY, then follow every step exactly. Pass `$ARGUMENTS` as the task description. Skip Step 0 (arguments are already validated). The sub-command's `AskUserQuestion` checkpoint handles the proceed/revise/stop decision.

**After this phase**: Use `/compact` to reduce context before proceeding. The research artifact path is all that carries forward.

**Transition**: Before starting Phase 2, display:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◆ Blueprint Progress
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ◆ Research     complete
  ▶ Plan         starting
  ◇ Execute      pending
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Phase 2: Planning

Read `.claude/commands/plan.md` FULLY, then follow every step exactly. Pass the research artifact path — skip Step 0 and the "no path provided" prompt. The sub-command's checkpoints handle design options, phase buy-in, and final review.

**After this phase**: Use `/compact` to reduce context before proceeding. The plan artifact path is all that carries forward.

**Transition**: Before starting Phase 3, display:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◆ Blueprint Progress
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ◆ Research     complete
  ◆ Plan         complete
  ▶ Execute      starting
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Phase 3: Execute

Read `.claude/commands/execute-plan.md` FULLY, then follow every step exactly. Pass the plan artifact path — skip Step 0 and the "no path provided" prompt.

Default mode (phase-by-phase with pauses) unless the user said "run all phases" or "skip pauses".

**After execution**: Display the completion banner:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◆ Blueprint Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ◆ Research     complete
  ◆ Plan         complete
  ◆ Execute      complete

  → <N> files changed
  → All checks passed

Validate: /validate-plan <plan-artifact-path>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Rules

- Sub-command files are the source of truth — follow them completely, don't abbreviate
- Checkpoints between phases are not optional
- If the user says "stop", always provide the exact command to resume from where they left off
- Use `/compact` between phases to keep context lean
- Always display the phase tracker banners at transitions

## Resuming

If stopped at any checkpoint, resume with the artifact path:

- **Restart research**: `/research <task description>`
- **Resume at planning**: `/plan <research-artifact-path>`
- **Resume at execution**: `/execute-plan <plan-artifact-path>`

The artifact paths encode all state needed to continue. Checkbox state in plan files tracks execution progress.
