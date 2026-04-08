---
description: Read a research artifact and create a detailed, phased implementation plan
model: opus
---

# Create Implementation Plan

Create a precise, actionable implementation plan. Work collaboratively — present options and get buy-in before writing. **No open questions allowed in the final plan.**

## User-Provided Context

$ARGUMENTS

---

## Step 1: Load Research Artifact

If `$ARGUMENTS` contains a file path, read it FULLY now. If no path provided, ask the user for one or offer to do lightweight research first.

---

## Step 2: Track Planning Progress

Use `TodoWrite` with tasks: read research + files, present understanding, present design options, resolve questions, get phase buy-in, write plan.

---

## Step 3: Read Referenced Files and Standards

Read all files from the research artifact's "Relevant Files" table. Read the relevant standards files for the file types being modified (see `_plans-config.md` for your project's standards locations). Check for project knowledge docs and feature-specific documentation.

---

## Step 4: Determine Artifact Path

Read `.claude/commands/_plans-config.md` and follow it to derive `$PLANS_DIR` and the artifact filename (use `plan-` prefix, write to `$PLANS_DIR/plans/`).

---

## Step 5: Present Understanding

Present as text (no user input needed yet):

- **Task understanding**: 1-2 sentences on what needs to happen
- **Current state**: Key file:line discoveries from the research and your own reading
- **Questions from code**: Anything the code reveals that wasn't in the research

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

Read the artifact file and output its full contents as markdown in the conversation so the user can review it in a formatted view.

---

## Step 11: Present Plan for Review

State the artifact path, then use `AskUserQuestion`:

- **Question**: "Plan is written. Are there additional requirements you want included?"
- **Options**: "Ready to implement" / "Add requirements" / "Revise phases" / "Stop here"

Handle each response accordingly. If scope exceeds research coverage, ask whether to run `/research` first.

To revise this plan later, run `/iterate-plan <path>`.
