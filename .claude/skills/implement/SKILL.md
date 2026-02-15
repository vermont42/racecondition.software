---
name: implement
description: Analyze a task file and plan its implementation
argument-hint: <filename>
---

# Implement a Task

## Argument

The task file is: $ARGUMENTS

If no filename was provided, stop immediately and tell the user:
"Usage: `/implement <filename>` — please provide the name of a file that defines the task."

## Instructions

1. Read the file specified above.
2. Analyze the task it defines.
3. If you have questions whose answers would help you make a better plan, ask the user using AskUserQuestion. Wait for answers before proceeding.
4. Once all questions are answered (or if none were needed), use the EnterPlanMode tool to switch to plan mode, then create an implementation plan.
