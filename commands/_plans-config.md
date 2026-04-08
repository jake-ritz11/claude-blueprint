# Shared Plans Config

This file is read by the research, plan, and execute commands to resolve paths and conventions.

## Derive Plans Directory

Run this to set `$PLANS_DIR`:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
PROJECT_KEY=$(echo "$REPO_ROOT" | sed 's|^/||; s|/|-|g')
PLANS_DIR="$HOME/.claude/projects/-${PROJECT_KEY}/plans"
mkdir -p "$PLANS_DIR"
```

## Artifact Naming

- Get branch/ticket: `git branch --show-current` — parse a ticket ID if present (e.g., `PROJ-1234`, `GH-42`)
- Create a kebab-case slug from the task description (4-6 words max)
- Research: `$PLANS_DIR/research-YYYY-MM-DD-TICKET-slug.md`
- Plan: `$PLANS_DIR/plan-YYYY-MM-DD-TICKET-slug.md`
- Omit the ticket segment if no ticket ID found in the branch name

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
