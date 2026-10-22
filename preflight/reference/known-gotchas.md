# Known Gotchas, Error Handling, and Success Indicators

## Error handling

| Situation | Response |
|---|---|
| Any MCP fails at health check (Step 0b) | Hard-stop. Show which MCPs failed and how to re-auth. Do NOT proceed with partial sources. |
| No rolling context | Omit milestones. Offer to scaffold after briefing. |
| All MCP servers fail | Follow zero-MCP flow (first run) or hard-stop with re-auth instructions (repeat run). |

## Known gotchas

- **Token expiry:** MCP tokens expire. Re-link at MCP Explorer.
- **Timezone:** Detect, never assume. Cross-check system and calendar.
- **Meeting prep:** Flag linked docs, do not read proactively.
- **Mondays:** 72-hour Slack scan + "This Week at a Glance."
- **Long threads:** Summarize from last 10 replies for threads > 50.
- **Bot noise:** Filter aggressively unless indicating failures.
- **Name detection:** Resolve from Calendar/Slack profile. Never ask.
- **Calendar past-date on all-day events:** Calendar events with a
  `date` field (all-day) instead of `dateTime` have no timezone info.
  They can appear as yesterday if the local UTC offset isn't applied
  before comparing to today. Always apply the detected local timezone
  offset to bare `date` values before filtering.
- **Slack Unix timestamp year:** Off-by-a-year errors in Unix epoch
  conversion produce NO visible error — the Slack API silently returns
  messages from the wrong year. Always validate that the computed epoch
  lands in the current year before passing timestamps to
  `slack_read_channel`. Quick sanity check: `(year - 1970) × 31557600`
  gives an approximate Jan 1 epoch for any year.

## Success indicators

- At least one populated section in output
- Sources footer lists all checked sources
- Config file created (first run) or read (repeat run)
- State file updated with scanned docs and timestamp after every run
- Previously dismissed items do not resurface
- No reasoning narration visible
- Follow-up prompt matches included sections only
