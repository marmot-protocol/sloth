---
description: Create a new git worktree and branch
---

# Create Git Worktree

Create a new git worktree in the `trees/` directory with the branch name provided as the argument.

## CRITICAL: This is a ONE-SHOT command

- **DO NOT ask any questions** - use `$ARGUMENTS` as the branch name directly
- The branch name IS the argument - no clarification needed
- Execute all steps automatically without prompting

## Execution Steps

### 1. Get Branch Name

The branch name is: `$ARGUMENTS`

If `$ARGUMENTS` is empty, report an error: "Usage: /create-git-worktree <branch-name>"

### 2. Create Worktree Directory

```bash
mkdir -p trees
```

### 3. Create the Worktree

Run this command from PROJECT_CWD:

```bash
git worktree add trees/$ARGUMENTS -b $ARGUMENTS 2>/dev/null || git worktree add trees/$ARGUMENTS $ARGUMENTS
```

This handles both cases:
- If the branch doesn't exist: creates it with `-b`
- If the branch already exists: checks it out in the worktree

### 4. Verify Creation

```bash
git worktree list | grep "trees/$ARGUMENTS"
```

### 5. Switch to the Worktree

**This is essential** - change into the new worktree directory:

```bash
cd trees/$ARGUMENTS
```

### 6. Confirm Ready

Report success with the current working directory and branch:

```bash
pwd
git branch --show-current
```

Tell the user they are now in the worktree and ready to work.
