---
description: Full research > plan > execute workflow in one command, with human verification between phases
model: opus
---

# Blueprint

End-to-end task execution: Research > Plan > Execute. Each phase writes an artifact and pauses for your review.

## User-Provided Context

$ARGUMENTS

---

## Workflow

1. **Research** > writes artifact to `~/.claude/projects/.../plans/`
2. **Plan** > writes artifact to same directory
3. **Execute** > implements phase by phase with verification pauses

---

## Phase 1: Research

Read `.claude/commands/research.md` FULLY, then follow every step exactly. Pass `$ARGUMENTS` as the task description. The sub-command's `AskUserQuestion` checkpoint handles the proceed/revise/stop decision.

---

## Phase 2: Planning

Read `.claude/commands/plan.md` FULLY, then follow every step exactly. Pass the research artifact path — skip the "no path provided" prompt. The sub-command's checkpoints handle design options, phase buy-in, and final review.

---

## Phase 3: Execute

Read `.claude/commands/execute-plan.md` FULLY, then follow every step exactly. Pass the plan artifact path — skip the "no path provided" prompt.

Default mode (phase-by-phase with pauses) unless the user said "run all phases" or "skip pauses".

---

## Rules

- Sub-command files are the source of truth — follow them completely, don't abbreviate
- Checkpoints between phases are not optional
- If the user says "stop", always provide the exact command to resume from where they left off
