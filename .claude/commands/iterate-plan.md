---
description: Update an existing plan based on feedback, new requirements, or execution learnings
model: opus
---

# Iterate Plan

Update an existing plan without starting over. Surgically modify affected phases while preserving completed work and unaffected sections.

## User-Provided Context

$ARGUMENTS

---

## Step 0: Check Arguments

If `$ARGUMENTS` is empty or contains only whitespace, present usage help following the Usage Help template from `_plans-config.md` and stop:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◇ Iterate Plan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Usage: /iterate-plan <plan-artifact-path>

Updates an existing plan based on feedback,
new requirements, or execution learnings.
Preserves completed phases.

Example:
  /iterate-plan ~/.claude/.../plan-2026-04-08-auth-api.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Do NOT proceed to Step 1. Return after showing usage.

---

## Step 1: Load the Plan

If `$ARGUMENTS` contains a file path, read the plan artifact FULLY. If no path provided, ask the user for one.

---

## Step 2: Load Associated Research

Read the research artifact path from the plan's header/frontmatter. If it exists, read it FULLY for context.

After reading the research artifact, compare its `commit` to current HEAD. If they differ significantly (5+ commits), flag: "The research this plan is based on may be outdated ({N} commits behind). Consider whether the changes affect your iteration."

---

## Step 3: Present Current State

Present using a formatted phase tracker:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ Iterating: <plan name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ◆ Phase 1: <name> — implemented
  ◆ Phase 2: <name> — implemented
  ◇ Phase 3: <name> — pending
  ◇ Phase 4: <name> — pending

Scope: <"What We're NOT Doing" summary>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use ◆ for phases with `- [x]` checkboxes (implemented) and ◇ for pending phases.

---

## Step 4: Understand What Changed

Use `AskUserQuestion`:

- **Question**: "What needs to change in this plan?"
- **Options**:
  1. **"New requirements"** — "Add scope that wasn't in the original plan"
  2. **"Feedback from execution"** — "Reality didn't match the plan during implementation"
  3. **"Scope change"** — "Remove, reorder, or resize existing phases"
  4. **"Other"** — "Describe the change"

---

## Step 5: Research if Needed

If the change requires understanding code you haven't read, spawn a targeted `Explore` agent to verify before modifying the plan. Do NOT update the plan based on assumptions.

---

## Step 6: Assess Impact

For each phase in the plan, determine: unaffected, needs modification, needs to be added, or needs to be removed. Present this impact assessment to the user.

**Critical**: If changes affect completed phases (those with checked boxes), flag this explicitly: "Phase [N] is already implemented. This change would require rework. Proceed?"

---

## Step 7: Get Buy-In on Changes

Use `AskUserQuestion`:

- **Question**: "Here are the proposed changes. Should I update the plan?"
- Present the specific modifications as options/preview
- **Options**: "Apply changes" / "Adjust" / "Cancel"

---

## Step 8: Update the Plan

Modify the plan artifact in place:

1. Update affected phase sections
2. Preserve all unaffected sections exactly as they are
3. Update the frontmatter (`status: draft` if completed phases are affected)
4. Append a `## Change Log` section at the bottom (or add to existing one):

```markdown
## Change Log

- **YYYY-MM-DD**: [Description of what changed and which phases were affected]
```

---

## Step 9: Present Updated Plan

Read the updated artifact. Before outputting its contents, present a header:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◆ Plan Updated
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then output the full artifact contents as markdown. Provide the artifact path for reference and the resume command: `/execute-plan <artifact-path>`.

---

## Rules

- Never silently modify completed phases — always flag and get explicit approval
- Preserve existing structure and formatting for unaffected sections
- If the change is large enough to invalidate the research, recommend running `/research` again instead
- Be skeptical of changes that seem to expand scope beyond the original research — ask if new research is needed
