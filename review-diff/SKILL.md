---
description: Open claudit for diff review with inline comments.
---

# Review Diff

Run the claudit diff review UI in foreground to review code changes and provide feedback.

## Steps:

1. Run `claudit` in foreground (NOT background) with no timeout
2. Wait for user to review diffs and submit feedback in the web UI
3. Check the signal in the output:
   - `[USER REQUEST]` → read `.claude/diff-comments.json`, address each comment, delete the file
   - `[USER REQUEST PARALLEL]` → read the **full output** for detailed instructions printed after the signal, follow them exactly
   - `[USER APPROVED]` → review complete, stop
4. Delete `.claude/diff-comments.json` when done

## Comment format

Comments in `.claude/diff-comments.json` have a `file` and optional `lineId`:
- **Line comment**: has `lineId` (e.g. `"none-42"`) — feedback on a specific line
- **File-level comment**: no `lineId` — feedback on the file as a whole
