---
name: review-superpowers
description: Opens claudit to review and add inline comments on a superpowers spec or implementation plan. Use after the brainstorming or writing-plans skill has produced a doc and you want to give detailed feedback before it's used downstream.
---

# Review Superpowers Spec or Plan

Opens claudit against the most recent superpowers spec or plan file in the current project, for inline commenting. These files are committed repo artifacts — Claude Code's native plan mode is not involved.

## When to use

- After **superpowers:brainstorming** writes a design to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`, before writing-plans runs.
- After **superpowers:writing-plans** writes a plan to `docs/superpowers/plans/YYYY-MM-DD-<feature>.md`, before execution.

## Usage

```bash
review-superpowers           # most recent file across specs/ and plans/
review-superpowers --spec    # most recent spec only
review-superpowers --plan    # most recent plan only
review-superpowers <path>    # explicit file
```

Comments are stored in `.claude/superpowers-comments.json` (project-local, separate from `/review-plan`'s storage).

## Addressing feedback

When the user asks to address their feedback:

1. Read `.claude/superpowers-comments.json`. If the file is missing, or its `comments` array is empty, there's nothing to address — tell the user "no comments left to address" and skip to step 7 (re-engage the workflow). Otherwise continue.
2. Read the file referenced (it's the spec or plan in `docs/superpowers/`).
3. Edit the file directly with the Edit tool. Do **not** enter Claude Code's plan mode — these are committed markdown files, not native-plan-mode plans.
4. After all comments are addressed:
   - If the file is under `specs/`, re-run the brainstorming spec self-review (placeholder/consistency/scope/ambiguity scan).
   - If the file is under `plans/`, re-run the writing-plans self-review (spec coverage, placeholder scan, type consistency).
5. Delete `.claude/superpowers-comments.json`.
6. Commit the revised file.
7. Re-engage the workflow:
   - If the file is under `specs/`, ask whether to proceed to **superpowers:writing-plans** to create the implementation plan.
   - If the file is under `plans/`, return to the writing-plans execution handoff: "Two execution options: 1. Subagent-Driven (recommended) — superpowers:subagent-driven-development. 2. Inline Execution — superpowers:executing-plans. Which approach?"

## Not the same as `/review-plan`

`/review-plan` is for Claude Code's native plan mode — files in `~/.claude/plans/`, gated by the ExitPlanMode hook. This skill is for superpowers' committed repo artifacts. Pick the one that matches the workflow you're in.
