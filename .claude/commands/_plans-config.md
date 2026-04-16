# Shared Plans Config

This file is read by the research, plan, and execute commands to resolve paths and conventions.

## Derive Plans Directory

Run this to set `$PLANS_DIR`:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
PROJECT_KEY=$(echo "$REPO_ROOT" | sed 's|^/||; s|/|-|g')
PLANS_DIR="$HOME/.claude/projects/-${PROJECT_KEY}/plans"
mkdir -p "$PLANS_DIR/research" "$PLANS_DIR/plans"
```

## Directory Structure

Artifacts are organized by type:

- `$PLANS_DIR/research/` — research artifacts
- `$PLANS_DIR/plans/` — plan artifacts

## Artifact Naming

- Get branch/ticket: `git branch --show-current` — parse a ticket ID if present (e.g., `PROJ-1234`, `GH-42`)
- Create a kebab-case slug from the task description (4-6 words max)
- Research: `$PLANS_DIR/research/research-YYYY-MM-DD-TICKET-slug.md`
- Plan: `$PLANS_DIR/plans/plan-YYYY-MM-DD-TICKET-slug.md`
- Omit the ticket segment if no ticket ID found in the branch name

## YAML Frontmatter

Every artifact starts with this frontmatter block:

```yaml
---
type: research|plan
date: YYYY-MM-DD
task: "<short description of the task>"
branch: <branch-name>
commit: <short-hash from git rev-parse --short HEAD>
ticket: <ticket-id or "none">
status: draft|reviewed|approved|validated
research: <path to research artifact, plan artifacts only>
---
```

## Artifact Size Guidelines

- **Research artifacts**: Target 150-250 lines. If over 300, the scope is too broad — split into multiple focused research artifacts.
- **Plan artifacts**: Target ~10% of expected implementation code length. A 200-line plan suggests ~2000 lines of implementation. If the plan exceeds this, consider splitting into sequential plans.

## Context Management

Each phase of the blueprint workflow (research, plan, execute) is designed to run in a fresh context window. Between phases, **prefer `/clear` over `/compact`** — the artifact file path is all that needs to carry forward, and a fresh window eliminates context rot entirely (versus a summarized one that still carries stale tokens).

Use `/compact` only when you need to preserve mid-task conversation state (for example, mid-correction where the user's recent steering still matters). In the normal phase-to-phase flow, `/clear` is the right tool.

This is the core principle: **artifacts are the product, not the conversation**. Keep conversation context lean; keep artifacts precise.

## Standards Files (Project-Specific)

> **Customize this section for your project.**
>
> Point to whatever coding standards docs your project maintains. Examples:
>
> - `.ai/coding-standards.md` — general TypeScript/JavaScript conventions
> - `.ai/testing-standards.md` — unit testing patterns
> - `.ai/component-standards.md` — framework-specific component rules
> - `docs/ARCHITECTURE.md` — system design and patterns
> - `CONTRIBUTING.md` — contribution guidelines
>
> The research and plan commands will read these files to ensure artifacts
> and generated code comply with your project's conventions.

Read the relevant standards files for the file types being modified. Also check for:

- A knowledge/gotchas directory if your project maintains one
- Feature-specific documentation near the code being changed

## Output Formatting

All commands share a small formatting vocabulary for conversation output (not artifact files). The goal is quiet output: content reads first, chrome is minimal, and banner weight matches semantic weight.

### Core rules

1. **Do not frame content with top + middle + bottom rules.** A single thin leading `─` rule is the only rule you should use, and only for "moment" checkpoints.
2. **No invented glyph vocabulary.** Do not use `◆ ◇ ▶ → · ━`. State is conveyed by words; hierarchy is conveyed by indentation and markdown bold.
3. **Use markdown.** `**bold**` for headings, `-` for plain bullets, indentation for sub-items. The render context supports it — use it.
4. **Only two symbols remain:** `✓` (check passed) and `✗` (check failed). They are universal pass/fail indicators and survive any render context.

### Symbols

| Symbol | Meaning | Usage |
|--------|---------|-------|
| ✓ | Check passed | `✓ Lint passed` |
| ✗ | Check failed | `✗ 3 test failures` |
| ─ | Thin rule character | Leading rule at checkpoint moments; inline delimiter in a phase marker (`── Phase 2 of 4 — Data Layer ──`). Not decorative. |

### Form 1 — Usage help (no frame)

When a command is invoked with empty `$ARGUMENTS`, show a pure-markdown usage section and stop:

```markdown
## `/<command>` — <short description>

<1-3 line longer description.>

**Usage:** `/<command> <arguments>`

**Example:** `/<command> <example args>`
```

### Form 2 — Phase tracker (inline, one line)

When showing workflow progress (used by `/blueprint` and at major checkpoints):

```
Progress: Research done. Plan in progress. Execute and Validate pending.
```

Use plain-English state words (`done`, `in progress`, `pending`). No glyphs.

### Form 3 — Checkpoint / status (thin leading rule + bold heading)

The "moment" banner — used for research complete, plan complete, artifact presentation, iteration updated. A single thin leading rule carries the weight; no trailing rule.

```
─────────────────────────────────────────────
**<Phase Name> — complete**

  <key finding 1>
  <key finding 2>
  <key finding 3>

  Artifact: <path>
```

### Form 4 — Phase start marker (execute, one line)

When starting a phase during `/execute-plan`:

```
── Phase 2 of 4 — Data Layer ──
```

One-line inline marker. Rule characters are used honestly (as rules, not decoration).

### Form 5 — Phase complete (execute)

When completing a phase — bold heading plus indented Automated / Manual subsections:

```
**Phase 2 of 4 — Data Layer complete**

  Automated:
    ✓ Lint passed
    ✓ Tests passed (42 specs)

  Manual checks:
    - Verify API response shape matches spec
    - Confirm migration runs cleanly
```

Pending manual checks use plain `-` bullets — they are just a list, not a state glyph.

### Form 6 — Workflow completion (same weight as checkpoint, stronger language)

Used by `/execute-plan` Step 11 as the final moment of a run. `/blueprint` does NOT emit its own Form 6 — execution's completion carries the close; adding a second Form 6 would duplicate weight and content.

```
─────────────────────────────────────────────
**Execution complete**

  <N> files changed.
  <N> phases completed.
  All automated checks passed.

  Next: review with `git diff`, then `/validate-plan <path>` or open a PR.
```

### Form 7 — Advisory (markdown, no frame)

For informational setup banners (session setup, context-heavy advisory). Reads like documentation, not a dashboard:

```markdown
## Session setup

**Environment**
- Branch: `<branch>` (ticket: `<ticket-id-or-none>`)
- Status: <clean | N modified files>

**For best results**
- **Model:** `claude-opus-4-7` (pinned in frontmatter)
- **Effort:** `xhigh` recommended (or `high` for budget work)
- **Mode:** After plan approval, Shift+Tab enables auto mode
- **Alerts:** Set task-completion notifications if your harness supports them

Proceeding to research.
```
