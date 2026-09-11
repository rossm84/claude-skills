---
name: review-plan
description: Opens the claudit web UI to review and add inline comments on the current plan file. Use this skill when you want to give detailed feedback on a plan that Claude has written.
---

# Review Plan

This skill opens the claudit web UI in plan review mode, allowing you to add inline comments to the current plan file.

## Usage

Run `/review-plan` when Claude is in plan mode and you want to add detailed feedback.

## What This Skill Does

1. Finds the most recent plan file in `~/.claude/plans/`
2. Opens claudit in plan review mode
3. Displays the plan file with line numbers
4. Allows you to click on any line to add a comment
5. Comments are saved to `~/.claude/plan-comments.json`
6. When you return to Claude, the comments are automatically injected as context
7. If you try to approve the plan (ExitPlanMode) with unaddressed comments, Claude will be blocked

## Instructions

When this skill is invoked, execute the following command:

```bash
claude-plan
```

This will:
- Find the most recent plan file in ~/.claude/plans/
- Open the claudit web UI in your browser
- Display the plan with inline comment support

After adding your comments in the UI, click "Submit" to save them. Then return to Claude and say "address my feedback" or continue your conversation - Claude will see your comments.

## Addressing Feedback

When the user returns and asks you to address their feedback:

1. **Check if you're in plan mode** - If not, enter plan mode first using EnterPlanMode
2. **Read the plan file** - The comments reference line numbers in the plan
3. **Read ~/.claude/plan-comments.json** - To see all feedback
4. **Revise the plan** - Address each comment by updating the plan file
5. **Clear comments when done** - Delete ~/.claude/plan-comments.json after addressing all feedback

If you're not in plan mode, you MUST enter plan mode before making changes to the plan file. The plan file is located in ~/.claude/plans/ - use the most recently modified one.
