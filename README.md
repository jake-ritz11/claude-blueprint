# Claude Blueprint

**Structured research > plan > execute workflow for Claude Code.** One command to go from task description to shipped code.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-blue.svg)](https://docs.anthropic.com/en/docs/claude-code)

## The Problem

AI coding tools don't fail on complex codebases because they lack intelligence — they fail because of **context bloat**. A single long session accumulates thousands of lines of context. Token utilization climbs past 80%. Output quality degrades silently.

**Without structure:** You're reviewing 2,000+ lines of accumulated context, hoping the AI remembered what mattered. It didn't.

**With Blueprint:** Work is broken into isolated phases — research, plan, implement — each producing a tight ~200-line artifact that gets handed off to the next phase in a fresh context window. You review ~200 lines of spec instead of 2,000 lines of code, and the AI starts each phase with only what it actually needs.

This approach is built on [Frequent Intentional Compaction (FIC)](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md) from HumanLayer's Advanced Context Engineering guide, validated on a 300k LOC Rust codebase where an engineer with zero Rust experience shipped a merged PR in about an hour.

## Quick Start

### 1. Install

```bash
curl -sL https://raw.githubusercontent.com/jake-ritz11/claude-blueprint/main/install.sh | sh
```

Or copy manually:

```bash
cp -r path/to/claude-blueprint/.claude .
```

### 2. Run

```
/blueprint Implement feature X that does Y
```

That's it. The command orchestrates the full research > plan > execute pipeline with human verification checkpoints between each phase.

## What It Produces

Blueprint generates structured artifacts at each phase. See real examples:

- [Sample Research Artifact](examples/sample-research-artifact.md) — codebase analysis with file:line references, data flows, and constraints
- [Sample Plan Artifact](examples/sample-plan-artifact.md) — phased implementation plan with verification checklists

<details>
<summary>Preview: Research artifact snippet</summary>

```markdown
## Relevant Files

| File                                | Lines | Purpose                                                    |
| ----------------------------------- | ----- | ---------------------------------------------------------- |
| src/routes/users.ts                 | 1-89  | Existing user endpoints — follows router pattern to extend |
| src/middleware/auth.ts              | 12-45 | Auth middleware — applied to all /users routes             |
| src/repositories/user.repository.ts | 1-67  | User repo — pattern to follow for preferences repo         |

## Existing Patterns

### Route Registration

All routes follow Express Router pattern with Zod validation middleware.
Routes are registered in `src/routes/index.ts` with a prefix.

### Repository Pattern

Database access uses a repository class per entity with standard
CRUD methods. All queries use parameterized prepared statements.
```

</details>

## How It Works

```
/blueprint "Add user preferences API"
```

The command orchestrates three phases, showing progress at each transition:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◆ Blueprint
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ▶ Research     starting        ← Spawns agents, maps codebase
  ◇ Plan         pending           Writes ~200-line artifact
  ◇ Execute      pending

Task: Add user preferences API
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

At each checkpoint you review findings, then context compacts and the next phase starts fresh:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◆ Research Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  → 12 relevant files identified
  → 3 patterns documented
  → 2 open questions for planning

Artifact: ~/.claude/.../research-2026-04-08-user-prefs.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Execution runs phase-by-phase with verification at each step:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
◆ Phase 2 of 3: Data Layer — Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Automated checks:
  ✓ Lint passed
  ✓ Tests passed (42 specs)

Manual checks needed:
  ◇ Verify API response shape matches spec
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

At any point: `/iterate-plan <path>` to revise the plan.

Each phase produces a standalone artifact with YAML frontmatter. You can stop at any checkpoint and resume later:

```
/plan <research-artifact-path>
/execute-plan <plan-artifact-path>
/iterate-plan <plan-artifact-path>
/validate-plan <plan-artifact-path>
```

## Commands

### Core Workflow

| Command         | Description                                                                                                                                                    |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/blueprint`    | Runs the full research > plan > execute pipeline with checkpoints between each phase. **Start here.**                                                          |
| `/research`     | Researches the codebase using specialized agents and writes a structured artifact with file:line refs, data flows, constraints, and open questions.            |
| `/plan`         | Reads a research artifact and produces a phased implementation plan with design options, verification checklists, and code snippets.                           |
| `/execute-plan` | Implements a plan phase by phase with verification pauses. Tracks progress via checkboxes, runs lint/tests, and recommends context compaction after 3+ phases. |

### Lifecycle Commands

| Command          | Description                                                                                                                 |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `/iterate-plan`  | Updates an existing plan based on feedback, new requirements, or execution learnings. Preserves completed phases.           |
| `/validate-plan` | Post-execution validation — runs all automated checks from all phases, verifies expected changes exist, reports deviations. |

### Shared Config

| File               | Description                                                                                                                                                             |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `_plans-config.md` | Shared config for all commands. Defines artifact naming, YAML frontmatter template, size guidelines, and standards file locations. **Customize this for your project.** |

## Customization

The commands are **project-agnostic**. Customize `_plans-config.md` to point at your project's coding standards and knowledge docs.

### Standards Files

The research, plan, and execute commands all read your project's standards files to ensure generated artifacts and code comply with your conventions:

```
# Example: your _plans-config.md Standards Files section

Read the relevant standards files per the task type:

| File type        | Standards file                    |
| ---------------- | --------------------------------- |
| *.tsx            | docs/component-guide.md           |
| *.test.ts        | docs/testing-standards.md         |
| *.css            | docs/css-conventions.md           |
| Other *.ts       | CONTRIBUTING.md                   |
```

See [`examples/`](examples/) for full configurations for Angular, React, and Python projects.

## Tips

- **Just run `/blueprint`** — The full pipeline end-to-end beats using individual commands piecemeal. Checkpoints between phases give you control without losing momentum.
- **Let it stop** — Reviewing the research artifact catches bad assumptions before they propagate into code. Reviewing the plan catches scope issues before implementation.
- **Use `/compact` between phases** — Each phase should start with minimal context. The artifact file path is all that needs to carry forward.
- **Resume from artifacts** — Artifacts persist. Pass the file path to `/plan` or `/execute-plan` to pick up where you left off. Checkbox state in plan files tracks execution progress.
- **Iterate don't restart** — Use `/iterate-plan` instead of starting over. It preserves completed work and surgically updates affected phases.
- **Validate at the end** — Run `/validate-plan` after execution to catch regressions across phases.
- **Opus recommended** — The commands specify `model: opus` in their frontmatter. The research and planning phases benefit from the stronger model's reasoning.

## Examples

See [`examples/`](examples/) for:

- Project configurations for Angular, React, and Python
- Sample research and plan artifacts showing what the workflow produces

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on suggesting improvements and submitting changes.

## License

MIT
