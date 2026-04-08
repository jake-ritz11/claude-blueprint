# Commit Changes

Review the current git changes and create a commit with an appropriate message.

## User Context

$ARGUMENTS

## Instructions

1. Run these commands in parallel to understand the changes:
   - `git status` - see what files are staged/unstaged
   - `git diff --staged` - see staged changes
   - `git diff` - see unstaged changes
   - `git log --oneline -5` - see recent commit style

1. Analyze the changes and write a clear, concise commit message that:
   - Starts with a type prefix (feat:, fix:, chore:, docs:, refactor:, test:)
   - Summarizes the "why" not just the "what"
   - Is under 72 characters for the first line
   - Incorporates any user-provided context above (if provided)

1. Stage all relevant changes with `git add`

1. Create the commit using a heredoc (the quoted delimiter prevents expansion):

```bash
git commit -m "$(cat <<'COMMIT_MSG'
<commit message here>

Co-Authored-By: Claude <noreply@anthropic.com>
COMMIT_MSG
)"
```

1. Show the result with `git log -1`

## Notes

- If there are no changes to commit, inform the user
- Do not push unless explicitly asked
- If pre-commit hooks fail, fix the issue and create a NEW commit (don't amend)
