# Claude Blueprint

A structured **research > plan > execute** workflow built as [Claude Code](https://docs.anthropic.com/en/docs/claude-code) slash commands. Makes complex task implementation more repeatable and less context-bloated by breaking work into artifact-driven phases with human verification checkpoints in between.

## Background

Built on the [Frequent Intentional Compaction (FIC)](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md) methodology from HumanLayer's Advanced Context Engineering guide.

The core insight: instead of letting one long session accumulate context bloat, you deliberately break work into three isolated phases — **research, plan, implement** — where each phase produces a tight written artifact (~200 lines) that gets handed off to the next phase in a fresh context window. You end up reviewing ~200 lines of spec rather than 2,000 lines of code, and the AI starts each phase with only what it actually needs.

**Why this matters**: AI coding tools don't fail on complex codebases due to lack of intelligence — they fail due to poor context management. Keeping token utilization at 40-60% through deliberate context structuring produces significantly better results than letting context grow unbounded.

The FIC approach was validated on a 300k LOC Rust codebase (BAML) — an engineer with zero Rust experience shipped a merged PR in about an hour using the workflow.

## Quick Start

### 1. Copy commands into your project

```bash
# From your project root
mkdir -p .claude/commands
cp commands/*.md .claude/commands/
```

### 2. Customize `_plans-config.md`

Edit `.claude/commands/_plans-config.md` to point at your project's standards/docs files. See [`examples/`](examples/) for Angular, React, and Python configurations.

### 3. Run it

```
/blueprint Implement feature X that does Y
```

That's it. The command orchestrates the full pipeline with checkpoints between each phase.

## Commands

### Core Workflow

| Command | Description |
| --- | --- |
| `/blueprint` | Runs the full research > plan > execute pipeline with checkpoints between each phase. **Start here.** |
| `/research` | Researches the codebase using specialized agents (locator, pattern finder, flow tracer) and writes a structured artifact with file:line refs, data flows, constraints, and open questions. Enforces a strict documentarian constraint — maps what exists without suggesting changes. |
| `/plan` | Reads a research artifact and produces a phased implementation plan. Presents design options for buy-in, resolves open questions, and structures each phase with specific file changes, code snippets, and split verification checklists (automated + manual). |
| `/execute-plan` | Implements a plan phase by phase with verification pauses. Tracks progress via checkboxes in the plan file, runs lint/tests, surfaces plan-vs-reality mismatches, and recommends context compaction after 3+ phases. |

### Lifecycle Commands

| Command | Description |
| --- | --- |
| `/iterate-plan` | Updates an existing plan based on feedback, new requirements, or execution learnings. Preserves completed phases and surgically modifies affected sections. |
| `/validate-plan` | Post-execution validation — runs all automated checks from all phases, verifies expected code changes exist, and reports deviations. |

### Shared Config

| File | Description |
| --- | --- |
| `_plans-config.md` | Shared config for all commands. Defines plans directory structure, artifact naming, YAML frontmatter template, size guidelines, and standards file locations. **Customize this for your project.** |

## How It Works

```
/blueprint "Add user preferences API"
        |
        v
  [Phase 1: Research]
        |
        |  Spawns specialized agents (locator, pattern finder, flow tracer)
        |  Reads critical files
        |  Writes research artifact (150-250 lines)
        |  >>> Checkpoint: review findings, proceed/revise/stop
        |  >>> /compact to reduce context
        |
        v
  [Phase 2: Plan]
        |
        |  Reads research artifact (compacted context)
        |  Presents understanding, then design options for buy-in
        |  Resolves all open questions
        |  Writes plan artifact with phased changes + verification gates
        |  >>> Checkpoint: review plan, adjust/approve/stop
        |  >>> /compact to reduce context
        |
        v
  [Phase 3: Execute]
        |
        |  Reads plan artifact (compacted context)
        |  Implements one phase at a time
        |  Runs automated verification after each phase
        |  Pauses at verification gates and phase boundaries
        |  Recommends /clear after 3+ phases
        |  >>> Checkpoint per phase: verify, then continue
        |
        v
  [Phase 4: Validate]  (optional)
        |
        |  Re-runs ALL automated checks from ALL phases
        |  Verifies expected changes exist in codebase
        |  Reports regressions and deviations
        |
        v
  [Done] — all files changed, tests passing, plan validated

  At any point:
  /iterate-plan <path>  — revise the plan based on feedback
```

Each phase produces a standalone artifact with YAML frontmatter in `~/.claude/projects/.../plans/`. You can stop at any checkpoint and resume later:

```
/plan ~/.claude/projects/-path/plans/research/research-2025-01-15-PROJ-123-user-prefs.md
/execute-plan ~/.claude/projects/-path/plans/plans/plan-2025-01-15-PROJ-123-user-prefs.md
/iterate-plan ~/.claude/projects/-path/plans/plans/plan-2025-01-15-PROJ-123-user-prefs.md
/validate-plan ~/.claude/projects/-path/plans/plans/plan-2025-01-15-PROJ-123-user-prefs.md
```

## Customization

The commands are designed to be **project-agnostic**. The main thing to customize is `_plans-config.md`, which tells the workflow where your project's coding standards and knowledge docs live.

### Standards Files

The research, plan, and execute commands all read your project's standards files to ensure generated artifacts and code comply with your conventions. You point to these in `_plans-config.md`.

You don't need a specific directory structure — just point to whatever docs your project already has:

```
# Example: your _plans-config.md Standards Files section

Read the relevant standards files per the task type:

| File type        | Standards file                    |
| ---------------- | --------------------------------- |
| `*.tsx`          | `docs/component-guide.md`         |
| `*.test.ts`      | `docs/testing-standards.md`       |
| `*.css`          | `docs/css-conventions.md`         |
| Other `*.ts`     | `CONTRIBUTING.md`                 |
```

See [`examples/`](examples/) for full configurations for Angular, React, and Python projects.

### Verification Commands

The `execute-plan.md` command references lint/test commands (Step 6). Update these to match your project's tooling.

## Tips

- **Just run `/blueprint`** — Running the full pipeline end-to-end beats using the individual commands piecemeal. The checkpoints between phases give you control without losing momentum.
- **Let it stop** — The checkpoints aren't just ceremony. Reviewing the research artifact catches bad assumptions before they propagate into code. Reviewing the plan catches scope issues before implementation.
- **Use `/compact` between phases** — This is the core FIC principle. Each phase should start with minimal context. The artifact file path is all that needs to carry forward.
- **Resume from artifacts** — If you stop mid-workflow, the artifacts are saved. Pass the file path to `/plan` or `/execute-plan` to pick up where you left off. Checkbox state in plan files tracks execution progress.
- **Iterate don't restart** — If a plan needs changes, use `/iterate-plan` instead of starting over. It preserves completed work and surgically updates affected phases.
- **Validate at the end** — Run `/validate-plan` after execution to catch regressions across phases. Earlier phases can break during later implementation.
- **Opus recommended** — The commands specify `model: opus` in their frontmatter. The research and planning phases benefit from the stronger model's reasoning. You can change this if needed.

## License

MIT
