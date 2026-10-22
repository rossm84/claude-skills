# Output Format, Phase 4, and Feedback Loop

## Top priority synthesis

Open with: **Today's top priority** — one sentence, using this order:

1. A blocker where you are the named owner (unblocking others > all)
2. An action item where a stakeholder is explicitly waiting on you
3. An overdue action item (past its stated deadline)
4. An action item or Slack thread due today
5. Nearest deadline within 3 days

Surface the item with the most downstream consequence if left undone.

## Section structure

Then structured sections: Calendar, Slack Triage, Action Items,
Blockers, Upcoming Milestones, Wrap-Up Draft. Close with sources
footer: `Slack: last 24h | Docs: last 7d | Calendar: today`

**Monday variant:** add "This Week at a Glance" after Calendar (key
dates, carried-over items, weekly theme).

**Section rules:**
- Populated: show data
- Empty (source available): header + "Nothing to report"
- Source unavailable: omit section, note in footer
- Zero MCP servers: follow zero-MCP flow

**Calendar — always a table.** Even when empty, render
`## Today's Calendar (0 meetings)` with a placeholder row.

## Staleness nudge rendering (from Step 0)

If the staleness check flagged either file as > 24h old, append a single
`## Heads up` section as the final block (above follow-up prompt):

> Your {file} is {N} days stale. Run `wrap-up` tonight to keep tomorrow's briefing sharp.

If both are stale, combine: "Your rolling context and wrap-up draft are
both stale — run `wrap-up` tonight." One nudge max per briefing.

## Three-bucket Slack render rules

Order: Action needed → Suggestions → FYI. Never reorder.

- Buckets with 0 items omitted entirely (header + divider drop out)
- Visual breaks (`---`) only between populated buckets
- All empty: render "Your Slack channels are quiet — nothing needs
  your attention right now."
- Promotion labels on DM items: `— addressed by name`, `— unreplied
  DM`, `— direct ask in thread`

---

## Phase 4: After the briefing

### First-run closing message

On first run only:
> "Tomorrow, just say **preflight** and you'll get a fresh briefing."

### Follow-up prompt

Dynamic follow-up matching included sections:
- Calendar → "prep for a meeting"
- Slack actions → "reply to a Slack thread"
- Doc tasks → "tackle an action item"
- Wrap-up draft → "review yesterday's wrap-up"
- Any Slack/action items → "dismiss an item I've handled"

If user doesn't engage: "That's your briefing. Say preflight tomorrow."

### Required closing line

After follow-up, always end with:
> Want to flag anything? Reply with "flag - <note>" and I'll log it.

### Reply to a Slack thread (draft)

1. List action-needed items by number.
2. User picks one.
3. Draft reply from briefing + thread context.
4. Call `slack_send_message_draft` — nothing auto-sends.
5. Add permalink to `.preflight-state.md` Handled Slack Items.

### Dismiss an item

1. List all surfaced items by number.
2. User picks which to dismiss.
3. Append to `.preflight-state.md` (Slack → permalinks, Docs → task).
4. Confirm: "Dismissed N items — won't appear tomorrow."

### State file write

After every session, update `.preflight-state.md`:
- Set `Last Run` to current ISO timestamp
- Update `Scanned Docs` with newly scanned doc IDs + modifiedTime
- Append dismissed or replied-to items
- Prune: 14 days (Slack), 30 days (docs, tasks, feedback)

---

## Feedback loop

A lightweight self-correction channel. The user flags something;
the skill logs it; the next briefing silently adjusts.

**Required on every run:**

1. End every briefing with the closing line above.
2. On next message matching `^flag\s*-\s*(.+)$`: append timestamped
   row to `## User Feedback` in `.preflight-state.md`. Reply:
   `"Logged. Will apply next briefing."`
3. At start of every run (after TTL prune), silently load feedback
   entries from last 30 days as self-correction guidance. Never render.
4. If a feedback item influenced output, append
   `Applied feedback: "<quote>" — <change>` near the bottom.
