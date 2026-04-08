---
description: Read a research artifact and create a detailed, phased implementation plan in ~/.claude/projects/.../plans/
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

Use `TodoWrite` with tasks: read research + files, present design options, resolve questions, get phase buy-in, write plan.

---

## Step 3: Read Referenced Files and Standards

Read all files from the research artifact's "Relevant Files" table. Read the relevant standards files for the file types being modified (see `_plans-config.md` for your project's standards locations). Check for project knowledge docs and feature-specific documentation.

---

## Step 4: Determine Artifact Path

Read `.claude/commands/_plans-config.md` and follow it to derive `$PLANS_DIR` and the artifact filename (use `plan-` prefix).

---

## Step 5: Present Understanding + Design Options

Present as text: task understanding (1-2 sentences), current state (key file:line discoveries), any questions from code.

Then use `AskUserQuestion` to get the user's decision on approach:

- Present 2-4 concrete approaches with pros/cons as options
- Mark recommended option with "(Recommended)"
- Use `preview` field for code patterns or architecture comparisons
- Bundle additional design questions as separate questions (up to 4 per call)

Verify assumptions with code — do NOT just accept what the user says without checking.

---

## Step 6: Resolve All Open Questions

If answers raise new questions, spawn a targeted `Explore` agent to verify. Do NOT write the plan with any unresolved questions.

---

## Step 7: Present Plan Structure for Buy-In

Present phase names with 1-sentence descriptions, then use `AskUserQuestion`:

- **Question**: "Does this phase structure look right?"
- **Options**: "Looks good" / "Adjust phases" / "Add a phase"

---

## Step 8: Write the Full Plan Artifact

Write to the path from Step 4. Required sections:

- **Header**: Date, Branch, Ticket, Research path
- **Overview**: 2-3 sentences — what, why, intended outcome
- **Current State**: What exists, what's missing, file:line refs
- **What We're NOT Doing**: Explicit out-of-scope items

**Per phase**:

- **Overview**: What it accomplishes and why it's in this order
- **Files to Change**: Each file with change summary and key code snippets
- **Automated Verification**: Checkboxes for lint, test commands, etc.
- **Manual Verification**: Checkboxes for UI/behavior testing

**Footer sections**: Testing Strategy, Standards Compliance (list which standards files apply), References.

All code snippets must comply with your project's coding standards.

---

## Step 9: Present the Artifact

Read the artifact file and output its full contents as markdown in the conversation so the user can review it in a formatted view.

---

## Step 10: Present Plan for Review

State the artifact path, then use `AskUserQuestion`:

- **Question**: "Plan is written. Are there additional requirements you want included?"
- **Options**: "Ready to implement" / "Add requirements" / "Revise phases" / "Stop here"

Handle each response accordingly. If scope exceeds research coverage, ask whether to run `/research` first.
