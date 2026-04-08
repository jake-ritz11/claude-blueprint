---
description: Research the codebase around a task and produce a research artifact in ~/.claude/projects/.../plans/
model: opus
---

# Research Codebase

Your ONLY job is to **document what exists** — not suggest improvements, not propose solutions, not critique.

## User-Provided Context

$ARGUMENTS

---

## Step 1: Determine Artifact Path

Read `.claude/commands/_plans-config.md` and follow it to derive `$PLANS_DIR` and the artifact filename (use `research-` prefix). Also run `git rev-parse --short HEAD` for the commit hash.

---

## Step 2: Read Any Directly Mentioned Files

If `$ARGUMENTS` references specific files, tickets, or documents — read them FULLY first (no limit/offset). Do this before spawning agents.

---

## Step 3: Check Accumulated Knowledge

If your project maintains a knowledge directory (e.g., `.ai/codebase-knowledge/`, `docs/knowledge/`), check it for relevant prior research. Also look for feature-specific docs near the code being investigated. This prevents re-discovering documented knowledge.

---

## Step 4: Decompose and Track

Use `TodoWrite` to create one task per research area (2-4 areas). Break the task into distinct focuses: where code lives, existing patterns, data flows, constraints.

---

## Step 5: Spawn Parallel Explore Agents

Launch 2-4 `Explore` agents in **parallel** (single message), each with a specific search focus, target directories, and instruction to return file:line references. Wait for ALL to complete before proceeding.

---

## Step 6: Read Critical Files

After agents return, read the most important identified files FULLY into context.

---

## Step 7: Write the Research Artifact

Write to the path from Step 1. Required sections (1 line description each — Claude formats the content):

- **Header**: Date, Branch, Commit, Ticket
- **Research Question**: Exact task being researched
- **Summary**: 2-4 sentences on what exists and key patterns
- **Relevant Files**: Table with File, Lines, Purpose
- **Existing Patterns to Follow**: Name, location (file:line), how to reuse
- **Data Flow**: Entry points, transformations, outputs with file:line refs
- **Constraints & Gotchas**: Each with file:line ref
- **Open Questions**: Things requiring human judgment
- **Code References**: All notable file:line refs with descriptions

Use real values throughout — never placeholder text.

---

## Step 8: Present the Artifact

Read the artifact file and output its full contents as markdown in the conversation so the user can review it in a formatted view.

---

## Step 9: Present Findings

Present a brief summary (key findings, key files, open questions), then use `AskUserQuestion`:

- **Question**: "Research is complete. How would you like to proceed?"
- **Options**:
  1. **"Proceed to planning"** — "Move on to /plan with this research artifact"
  2. **"Revise research"** — "Provide feedback to update or deepen the research"
  3. **"Stop here"** — "End here — use /plan later when ready"

Handle each response accordingly. Always provide the full artifact path for resume commands.

---

## Rules

- Always complete Steps 1-2 before spawning agents; always wait for all agents before writing
- Subagents do the deep file reading; main context synthesizes
- All file:line refs are required — vague descriptions without locations are not useful
- If the user asks follow-ups, append a `## Follow-up Research` section rather than rewriting
