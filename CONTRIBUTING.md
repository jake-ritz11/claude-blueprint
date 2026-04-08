# Contributing to Claude Blueprint

Thanks for your interest in improving Blueprint. This guide covers how to suggest changes and submit contributions.

## Suggesting Improvements

Open an issue first before starting work. This lets us discuss the approach and avoid duplicate effort. Use the issue templates for bug reports and feature requests.

## Submitting Changes

1. Fork the repository
2. Create a branch from `main` (`git checkout -b your-branch-name`)
3. Make your changes
4. Submit a pull request

## Command File Conventions

If you're modifying or adding command files in `.claude/commands/`, follow these conventions:

- **Frontmatter**: Every command file starts with YAML frontmatter specifying `model`, `description`, and `allowedTools`
- **Step numbering**: Use `## Step N:` headers for sequential steps
- **AskUserQuestion checkpoints**: Include human verification pauses at key decision points using the `AskUserQuestion` tool
- **Shared config**: Reference `_plans-config.md` for artifact naming, directory paths, and standards file locations — don't hardcode these in individual commands

## Testing Changes

There's no automated test suite — these are markdown command files. To test:

1. Copy your modified `.claude/commands/` directory into a real project
2. Run `/blueprint` with a realistic task description
3. Verify the full flow: research artifact is generated, plan is generated from research, execution follows the plan
4. Check that artifacts have valid YAML frontmatter and all expected sections
5. Confirm that checkpoints pause for human review at the right moments

## Code of Conduct

Be respectful and constructive. Focus feedback on the work, not the person.
