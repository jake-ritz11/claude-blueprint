# Claude Blueprint

A structured **research > plan > execute** workflow built as [Claude Code](https://docs.anthropic.com/en/docs/claude-code) slash commands. The idea is to make complex task implementation more repeatable and less context-bloated by breaking work into artifact-driven phases with human verification checkpoints in between.

## Background

Inspired by the [Frequent Intentional Compaction (FIC)](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md) methodology from HumanLayer's Advanced Context Engineering guide.

The core insight: instead of letting one long session accumulate context bloat, you deliberately break work into three isolated phases — **research, plan, implement** — where each phase produces a tight written artifact (~200 lines) that gets handed off to the next phase in a fresh context window. You end up reviewing ~200 lines of spec rather than 2,000 lines of code, and the AI starts each phase with only what it actually needs.

The FIC approach was validated on a 300k LOC Rust codebase (BAML) — an engineer with zero Rust experience shipped a merged PR in about an hour using the workflow.

In practice, this outperforms Claude Code's native `/plan` — better output quality and significantly less context bloat on longer tasks.

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
| `/blueprint` | Runs the full research > plan > execute pipeline in one shot with checkpoints between each phase. **Start here.** |
| `/research` | Researches the codebase around a task and writes a structured artifact to `~/.claude/projects/.../plans/`. Spawns parallel Explore agents, then synthesizes findings into a doc with file:line refs, data flows, constraints, and open questions. |
| `/plan` | Reads a research artifact and produces a phased implementation plan. Presents design options for buy-in, resolves open questions, and structures each phase with specific file changes, code snippets, and verification checklists. |
| `/execute-plan` | Implements a plan phase by phase, pausing for human verification between each. Tracks progress via TodoWrite, runs lint/tests, and surfaces plan-vs-reality mismatches instead of silently improvising. |

### Supporting Commands

| Command | Description |
| --- | --- |
| `/code-coverage` | Analyzes branch changes against a base branch, identifies coverage gaps, and feeds targets into the blueprint workflow to generate tests. *Work in progress.* |
| `/review-changes` | Reviews code changes against project standards before creating a PR. Supports quick mode (standards only) and full mode (lint + tests + coverage). |
| `/pr-summary` | Generates a copy-pasteable PR summary via three-dot diff against a base branch. |
| `/commit` | Reviews git changes and creates a commit with a conventional commit message. |

### Shared Config

| File | Description |
| --- | --- |
| `_plans-config.md` | Shared config for research/plan commands. Defines plans directory path, artifact naming conventions, and which standards files to read. **Customize this for your project.** |

## How It Works

```
/blueprint "Add user preferences API"
        |
        v
  [Phase 1: Research]
        |
        |  Spawns parallel Explore agents
        |  Reads critical files
        |  Writes research artifact (~200 lines)
        |  >>> Checkpoint: review findings, proceed/revise/stop
        |
        v
  [Phase 2: Plan]
        |
        |  Reads research artifact (fresh context)
        |  Presents design options for buy-in
        |  Resolves all open questions
        |  Writes plan artifact with phased changes
        |  >>> Checkpoint: review plan, adjust/approve/stop
        |
        v
  [Phase 3: Execute]
        |
        |  Reads plan artifact (fresh context)
        |  Implements one phase at a time
        |  Runs lint/tests after each phase
        |  >>> Checkpoint per phase: verify, then continue
        |
        v
  [Done] — all files changed, tests passing
```

Each phase produces a standalone artifact in `~/.claude/projects/.../plans/`. You can stop at any checkpoint and resume later:

```
/plan ~/.claude/projects/-path/plans/research-2025-01-15-PROJ-123-user-prefs.md
/execute-plan ~/.claude/projects/-path/plans/plan-2025-01-15-PROJ-123-user-prefs.md
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

The execute and review commands reference lint/test commands. Update these references in the command files to match your project's tooling:

- `execute-plan.md` Step 5 — your lint and test commands
- `review-changes.md` Phase 1 — your validation tools
- `code-coverage.md` Step 4 — your coverage runner

## Tips

- **Just run `/blueprint`** — Running the full pipeline end-to-end beats using the individual commands piecemeal. The checkpoints between phases give you control without losing momentum.
- **Let it stop** — The checkpoints aren't just ceremony. Reviewing the research artifact catches bad assumptions before they propagate into code. Reviewing the plan catches scope issues before implementation.
- **Resume from artifacts** — If you stop mid-workflow, the artifacts are saved. Pass the file path to `/plan` or `/execute-plan` to pick up where you left off.
- **Opus recommended** — The commands specify `model: opus` in their frontmatter. The research and planning phases benefit from the stronger model's reasoning. You can change this if needed.

## License

MIT
