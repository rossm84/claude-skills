# State Format — `.preflight-state.md`

## Purpose

Persists handled items between sessions so the same threads and action
items don't resurface. Read at the start of every run. If the file
doesn't exist, treat everything as new (first run).

## Filtering rules

Use the state during Phase 3 to filter:
- **Slack:** skip threads whose permalink appears in `Handled Slack Items`
- **Google Docs:** skip docs whose ID + modifiedTime match `Scanned Docs`
- **Action items:** omit items listed in `Dismissed Action Items`

After the briefing, update `.preflight-state.md`. See the output format
reference for the write-back flow.

## File template

```markdown
## Last Run
<ISO 8601 timestamp>

## Handled Slack Items
| Permalink | Dismissed on | Reason |
|---|---|---|

## Scanned Docs
| Doc ID | Title | Last Modified | Scanned On |
|---|---|---|---|

## Dismissed Action Items
| Doc | Task | Dismissed on |
|---|---|---|

## User Feedback
| When | Source | Note |
|---|---|---|
```

## TTL rules

Prune on every run before using state:
- Slack items: 14 days
- Docs, tasks, user feedback: 30 days
- Entries without a timestamp: treated as fresh (kept)

The `User Feedback` section is populated by the Feedback loop (see
output-format.md). Read silently at start-of-run — never rendered in
the briefing.
