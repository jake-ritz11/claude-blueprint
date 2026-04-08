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

Each phase of the blueprint workflow (research, plan, execute) is designed to run in a fresh or compacted context window. Between phases, use `/compact` to reduce context. The artifact file path is all that needs to carry forward between phases.

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
