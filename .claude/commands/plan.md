---
description: Read a research artifact and create a detailed, phased implementation plan
model: opus
---

# Create Implementation Plan

Create a precise, actionable implementation plan. Work collaboratively — present options and get buy-in before writing. **No open questions allowed in the final plan.**

## User-Provided Context

$ARGUMENTS

---

## Step 0: Check Arguments

If `$ARGUMENTS` is empty or contains only whitespace, present usage help following the Usage Help template from `_plans-config.md` and stop:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◇ Plan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Usage: /plan <research-artifact-path>

Reads a research artifact and creates a
phased implementation plan with design
options, verification checklists, and
code snippets.

Example:
  /plan ~/.claude/.../research-2026-04-08-auth-api.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Do NOT proceed to Step 1. Return after showing usage.

---

## Step 1: Load Research Artifact

If `$ARGUMENTS` contains a file path, read it FULLY now. If no path provided, ask the user for one or offer to do lightweight research first.

After reading the artifact, compare its frontmatter `commit` field to current `git rev-parse --short HEAD`. If they differ, warn the user:

"This research was written at commit `{artifact_commit}`, but you're now at `{current_commit}` ({N} commits ahead). Files referenced may have changed."

Use `AskUserQuestion`:
- **"Continue anyway"** — Proceed with the existing research
- **"View what changed"** — Run `git diff --stat {artifact_commit}..HEAD` and present the results, then re-ask
- **"Stop and re-research"** — End planning, provide the `/research` command to rerun

---

## Step 2: Track Planning Progress

Use `TodoWrite` with tasks: read research + files, present understanding, present design options, resolve questions, get phase buy-in, write plan.

---

## Step 3: Read Referenced Files and Standards

Read the files from the research artifact's "Relevant Files" table that are most critical — prioritize files being modified and interface files. **Cap at 10 files** to preserve context for planning. Read only the standards files relevant to the file types being modified (check `_plans-config.md` for mappings). If no mapping exists, read at most 2 standards files.

---

## Step 4: Determine Artifact Path

Read `.claude/commands/_plans-config.md` and follow it to derive `$PLANS_DIR` and the artifact filename (use `plan-` prefix, write to `$PLANS_DIR/plans/`).

---

## Step 5: Present Understanding

Present with a formatted header:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ Planning: <task name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then present (no user input needed yet):

- **Task**: 1-2 sentences on what needs to happen
- **Key files**: Most critical file:line discoveries from the research and your own reading
- **New findings**: Anything the code reveals that wasn't in the research

Verify assumptions with code — do NOT just accept what the user says without checking.

---

## Step 6: Present Design Options

Use `AskUserQuestion` to get the user's decision on approach:

- Present 2-4 concrete approaches with pros/cons as options
- Mark recommended option with "(Recommended)"
- Use `preview` field for code patterns or architecture comparisons
- Bundle additional design questions as separate questions (up to 4 per call)

---

## Step 7: Resolve All Open Questions

If answers raise new questions, spawn a targeted `Explore` agent to verify. Do NOT write the plan with any unresolved questions.

---

## Step 8: Present Plan Structure for Buy-In

Present phase names with 1-sentence descriptions, then use `AskUserQuestion`:

- **Question**: "Does this phase structure look right?"
- **Options**: "Looks good" / "Adjust phases" / "Add a phase"

---

## Step 9: Write the Full Plan Artifact

Write to the path from Step 4. Start with the YAML frontmatter from `_plans-config.md` (type: plan, status: draft). Include the research artifact path in the header.

Required sections:

- **Overview**: 2-3 sentences — what, why, intended outcome
- **Current State**: What exists, what's missing, file:line refs
- **What We're NOT Doing**: 3-5 specific items, each with a brief rationale for why it's excluded. This section prevents scope creep during execution.

**Per phase**:

- **Overview**: What it accomplishes and why it's in this order
- **Files to Change**: Each file with change summary and key code snippets
- **Automated Verification**: Checkboxes for runnable commands only (lint, test, build). These must be commands that can be copy-pasted into a terminal.
- **Manual Verification**: Checkboxes for human-observable behaviors only (click X, verify Y appears, confirm Z works).

**For plans with 5+ phases**: Insert a `### Verification Gate` section between every 2-3 phases. State what should be fully working at that point and what the user should test before continuing. These gates are mandatory stops during execution.

**Footer sections**: Testing Strategy, Standards Compliance (list which standards files apply), References.

All code snippets must comply with your project's coding standards.

---

## Step 10: Present the Artifact

Read the artifact file. Before outputting its contents, present a header:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◆ Plan Artifact
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then output the full artifact contents as markdown in the conversation so the user can review it in a formatted view.

---

## Step 11: Present Plan for Review

Present a formatted status banner following the Status Banner template from `_plans-config.md`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◆ Plan Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  → <N> phases defined
  → <N> files to modify
  → <N> verification checks

Artifact: <full artifact path>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then use `AskUserQuestion`:

- **Question**: "Plan is written. Are there additional requirements you want included?"
- **Options**:
  1. **"Ready to implement"** — "Proceed to execution"
  2. **"Add requirements"** — "Add scope or requirements to the plan"
  3. **"Revise phases"** — "Change how the phases are structured"
  4. **"Stop here"** — "End here — resume later with `/execute-plan <artifact-path>`"

Handle each response accordingly. When the user chooses "Stop here", always provide the exact resume command with the full artifact path. If scope exceeds research coverage, ask whether to run `/research` first.

To revise this plan later, run `/iterate-plan <path>`.
