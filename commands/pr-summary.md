Generate a PR summary for the current branch. Output the summary as a **raw markdown code block** (fenced with triple backticks) so the user can copy-paste it directly into a PR description. Do NOT render it as prose or formatted output.

## Steps

1. Determine the base branch. If `$ARGUMENTS` is provided, use that as the base branch. Otherwise default to `main`.
2. Fetch the latest base branch from origin: `git fetch origin <base>` — this is critical so the diff matches what GitHub will show in the PR, not a stale local copy.
3. Run `git log origin/<base>..HEAD --oneline --first-parent --no-merges` to see only the commits made directly on this branch.
4. Run `git diff origin/<base>...HEAD` to see the three-dot diff (what GitHub shows in the PR). This automatically excludes changes that came in via merging the base branch.
5. Analyze the branch's own commits and their diffs to understand what changed and why. Ignore tooling/docs files (e.g., `.claude/commands/`, `.ai/`, `docs/internal/`) — these are not PR-worthy changes.
6. Output the summary inside a fenced code block using exactly this format:

```
# Purpose of PR

<One sentence describing the overall goal — written as a phrase, not a bullet point. Mention the major themes separated by commas if there are several.>

## Changes

### <Area of Work 1>
- **`ClassName.methodOrField`** — what changed and why (explain the benefit or motivation)
- **`concept or pattern name`** — description of the change
- **Removed X** — what was removed and why

### <Area of Work 2>
- **Bold label** — explanation

### Tests
- <What was added/updated and why>
```

## Guidelines

- Group changes into named `###` subsections by area of work
- Use `**bold key** — description` pattern within each subsection
- Class/method/field names are fine to reference; do NOT reference file paths
- Each bullet should explain the _why_, not just the _what_
- Include a "Tests" subsection if there are notable test changes
- Keep it tight — no fluff, no redundancy
- The entire output must be wrapped in a fenced code block so the user can copy it
