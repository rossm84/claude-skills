# Feedback loop

A lightweight self-correction channel. The user flags something they
didn't like; the skill logs it; the next briefing silently reads the
feedback and adjusts. No top-of-briefing display — the correction shows
up in the briefing content itself.

## 1. End-of-briefing prompt

After all other output (follow-up prompt, any applied-feedback footer),
append as the final line:

```markdown
---
Want to flag anything? Reply with "flag - <note>" and I'll log it.
```

One line under a horizontal rule. No emoji, no elaboration.

## 2. Detecting feedback on the next user message

Check any user message for this pattern at the start (case-insensitive,
whitespace-tolerant):

```
^flag\s*-\s*(.+)$
```

If matched:

1. Append a row to `.preflight-state.md` under `## User Feedback`:
   ```
   | <ISO timestamp> | flag | <verbatim note from user> |
   ```
   Create the section + table if missing.
2. Reply with a single line: `"Logged. Will apply next briefing."` Do
   not expand or summarize back.
3. Continue handling any other intent in the same message normally.

The companion `slack-triage` skill uses the same `flag -` prefix and
writes to the same section — distinguished by the `Source` column.

## 3. Start-of-briefing silent read

After state-tracking prune, read `## User Feedback` (if present) and
filter to entries from the last **30 days**.

Hold the filtered entries as **self-correction guidance** for this run
only. Do NOT display them, echo them back, or list them anywhere above
the briefing. Interpret as constraints on tone, framing, inclusion, and
confidence level.

## 4. Applied-feedback footer (conditional, silent by default)

ONLY IF a feedback item directly influenced output this run, append a
one-liner per applied item near the bottom — above the end-of-briefing
feedback prompt's horizontal rule:

```
Applied feedback: "that [colleague] inference was a stretch" — softened
the [colleague] → design review suggestion to cite their Tuesday
comment as the observed signal rather than asserting availability.
```

Format: `Applied feedback: "<quoted feedback>" — <specific change>.`

**If no feedback influenced this run, stay silent.** Do NOT emit
`"Applied feedback: none"`, do NOT list loaded feedback. The correction
shows up in the briefing content itself.

## 5. State format addition

`.preflight-state.md` gains a `## User Feedback` section:

```markdown
## User Feedback
| When | Source | Note |
|---|---|---|
| 2026-04-22T14:30:00+02:00 | flag | that [colleague] inference was a stretch |
| 2026-04-22T09:15:00+02:00 | flag | don't address me by first name in drafts |
```

Subject to the 30-day TTL prune. Entries without a timestamp are kept
(treated as fresh).
