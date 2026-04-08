---
description: Research the codebase around a task and produce a research artifact
model: opus
---

# Research Codebase

## Critical Constraint

You are a **documentarian**. Document what IS, never what SHOULD BE.

If you catch yourself writing words like "should", "could improve", "consider", or "recommend" — delete them. Research that contains suggestions, critiques, or proposed solutions is **failed research**. Your only job is to map the territory so the planning phase has accurate information.

## User-Provided Context

$ARGUMENTS

---

## Step 1: Determine Artifact Path

Read `.claude/commands/_plans-config.md` and follow it to derive `$PLANS_DIR` and the artifact filename (use `research-` prefix, write to `$PLANS_DIR/research/`). Also run `git rev-parse --short HEAD` for the commit hash.

---

## Step 2: Read Any Directly Mentioned Files

If `$ARGUMENTS` references specific files, tickets, or documents — read them FULLY first (no limit/offset). Do this before spawning agents.

---

## Step 3: Check Accumulated Knowledge

Search for prior knowledge that prevents re-discovering documented facts:

1. Look for directories named `knowledge`, `docs`, `.ai`, `gotchas`, or `architecture` at the repo root. If found, grep for the task's key terms in markdown files under these directories.
2. Check if prior research artifacts exist in `$PLANS_DIR/research/`. If so, read their frontmatter to check for relevance to the current task.
3. Look for feature-specific documentation near the code being investigated (e.g., a README.md in the relevant module directory).

---

## Step 4: Decompose and Track

Use `TodoWrite` to create one task per research area (2-4 areas). Break the task into distinct focuses based on what the planning phase will need: where code lives, existing patterns, data flows, constraints.

---

## Step 5: Spawn Specialized Agents

Launch 2-3 agents in **parallel** (single message). Choose from these three agent patterns based on the task:

### Locator Agent
Use when you need to find where relevant code lives.

> "Find all files related to [specific aspect of the task]. Return: file path, relevant line ranges, and a one-sentence purpose for each file. Organize by: implementation files, test files, configuration, type definitions. Do NOT analyze or summarize — just locate and categorize. You are a documentarian, not a critic."

### Pattern Finder Agent
Use when you need to understand existing patterns the implementation should follow.

> "Find existing patterns for [specific pattern type] in the codebase. For each pattern found, return: pattern name, file:line location, the exact code snippet (10-20 lines), and where else it's reused. Do NOT suggest new patterns or evaluate existing ones. You are a documentarian, not a critic."

### Flow Tracer Agent
Use when you need to understand how data or control flows through the system.

> "Trace the data/control flow for [specific flow]. Return: entry point (file:line), each transformation step with what happens (file:line), exit point (file:line). Include error handling paths. Do NOT suggest improvements to the flow. You are a documentarian, not a critic."

Select 2-3 of these based on the task. Not every task needs all three. Wait for ALL agents to complete before proceeding.

---

## Step 6: Read Critical Files

After agents return, read the most important identified files FULLY into context. Prioritize files that will be directly modified or that define the interfaces/contracts the implementation must follow.

---

## Step 7: Write the Research Artifact

Write to the path from Step 1. Start with the YAML frontmatter from `_plans-config.md` (type: research, status: draft).

Required sections:

- **Research Question**: Exact task being researched
- **Summary**: 2-4 sentences on what exists and key patterns found
- **Relevant Files**: Table with File, Lines, Purpose columns
- **Existing Patterns to Follow**: Name, location (file:line), how to reuse
- **Data Flow**: Entry points, transformations, outputs with file:line refs
- **Constraints & Gotchas**: Each with file:line ref and explanation
- **Open Questions**: Things requiring human judgment before planning can proceed
- **Code References**: All notable file:line refs with descriptions

Use real values throughout — never placeholder text. Target 150-250 lines.

---

## Step 8: Present the Artifact

Read the artifact file and output its full contents as markdown in the conversation so the user can review it in a formatted view.

---

## Step 9: Checkpoint

Present a brief summary (key findings, key files, open questions), then use `AskUserQuestion`:

- **Question**: "Research is complete. How would you like to proceed?"
- **Options**:
  1. **"Proceed to planning"** — "Move on to /plan with this research artifact"
  2. **"Revise research"** — "Provide feedback to update or deepen the research"
  3. **"Stop here"** — "End here — use /plan later when ready"

Handle each response accordingly. Always provide the full artifact path for resume commands.

---

## Handling Corrections (Directional Steering)

If the user says the research findings are wrong or off-track, do NOT attempt to patch the artifact in place. Compounding on bad research produces worse results than restarting.

Instead:

1. Acknowledge the correction
2. Ask the user what the correct direction is
3. Restart from Step 4, incorporating the corrective context directly into the agent instructions so they search in the right direction

---

## Rules

- Always complete Steps 1-3 before spawning agents; always wait for all agents before writing
- Subagents do the deep file reading; main context synthesizes
- All file:line refs are required — vague descriptions without locations are not useful
- If the user asks follow-ups, append a `## Follow-up Research` section rather than rewriting
- The documentarian constraint applies to agents too — include it in every agent prompt
