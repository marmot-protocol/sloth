---
name: create-git-worktree
description: Create an isolated git worktree and branch for parallel development. Use when starting work on a new issue, feature, or bug fix that should be isolated from the main working directory.
---

# Git Worktree Creation

Use the `/create-git-worktree` command to create a new worktree and branch for isolated parallel development.

## Usage

```
/create-git-worktree <branch-name>
```

The command will:
1. Create a worktree at `trees/<branch-name>/`
2. Create the branch if it doesn't exist (or check it out if it does)
3. **Switch you into the worktree directory** so you're ready to work

## When to Use

- Starting work on a new issue or task
- Creating a separate workspace for a feature or bug fix
- Setting up parallel development environments
- Any time you need isolated work that won't affect the main directory

## Example

To start work on issue #42:

```
/create-git-worktree issue-42-fix-token-decryption
```

After running, you'll be in `trees/issue-42-fix-token-decryption/` on the `issue-42-fix-token-decryption` branch, ready to start coding.
