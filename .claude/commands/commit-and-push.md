---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git push:*), Bash(git branch:*), Bash(git diff:*), Bash(git log:*)
description: Stage all changes, commit with a message, and push to remote
argument-hint: [commit message]
---

# Commit and Push All Changes

## Current State

Git status:
!`git status`

Current branch:
!`git branch --show-current`

Recent commits (for style reference):
!`git log --oneline -5`

## Task

1. Stage all changes with `git add .`
2. Create a commit with the message: $ARGUMENTS
   - If no message is provided, analyze the changes and create an appropriate descriptive message
   - Follow the commit message style shown in recent commits above
3. Push to the remote repository with `git push`

## Commit Message Guidelines

- Use imperative mood ("add feature" or "add post", not "added feature" or "added post")
- Keep the first line concise and descriptive
- For commits you generate, end with the standard signature:

  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>

## Error Handling

- If there are no changes to commit, inform the user
- If push fails due to remote changes, suggest pulling first
- Never force push unless explicitly requested
