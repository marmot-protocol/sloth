---
description: Verify and fix an issue from GitHub
---

# Fix GitHub Issue

Verify an issue from GitHub is valid, create a worktree to work on it, fix the issue, and create a PR.

## Instructions

### 1. Parse and Validate Arguments

- Read ISSUE_NUMBER from $ARGUMENTS
- Accept: bare number (`5`), issue number (`#5`), or full URL (`https://github.com/org/repo/issues/5`)
- Extract just the number. If parsing fails, report an error and stop.

### 2. Validate Issue

- Fetch the issue using `gh issue view <ISSUE_NUMBER>`
- Read any files in the codebase related to the issue to understand context
- Determine if this is a valid problem, feature, or task worth working on
- If not valid, explain why and stop
- If valid, continue

### 3. Create Worktree

- Create a short ISSUE_DESCRIPTION from the issue title (lowercase, hyphens, no special chars)
- Set BRANCH_NAME to `issue-<ISSUE_NUMBER>-<ISSUE_DESCRIPTION>`
- Run: `/create-git-worktree <BRANCH_NAME>`
- You are now in the worktree directory, ready to work

### 4. Fix the Issue

- Implement the fix or feature
- Run quality checks: `just ci`
- Check code coverage: `just coverage-text`
  - All quality checks must pass
  - Code coverage must be equal or greater than HEAD
- If checks fail, fix issues and re-run until passing

### 5. Create PR

- Commit changes with a descriptive message
- Create a PR: `gh pr create --fill`
- Include `Closes #<ISSUE_NUMBER>` in the PR body

### 6. Report

After successful PR creation, provide this report:

```
✅ Issue #<ISSUE_NUMBER> Successfully Completed!

📁 Worktree:
   Location: trees/<BRANCH_NAME>
   Branch: <BRANCH_NAME>

🔗 GitHub:
   Issue: <FULL_ISSUE_URL>
   PR: <FULL_PR_URL>

📝 Summary:
   <Summary of changes made>
```
