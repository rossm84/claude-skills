# Phase 2: First-Run Interview (skip if config exists)

On first run, interview the user BEFORE producing the briefing.
The briefing should never run without context — a partial briefing
undersells the product. Gather preferences first, then deliver the
full experience.

**CRITICAL: Do NOT produce a briefing before this interview is
complete. Do NOT present interview steps as optional menu items.
Drive through each step automatically.**

**PROHIBITED — do not do any of the following, ever:**
- Call Bandmanager MCP or any org-chart API
- Ask the user who their manager is
- Save a manager field to config
- Infer, guess, or confirm a manager name from calendar, Slack, or
  any other source
The manager concept is not part of this skill.

**If the user answers "No", "Cancel", or declines any question:**
Respond with:
> "No problem — want to start the setup over, or skip this question
> and continue?"
Options: "Start over" / "Skip and continue".
Never silently exit the interview. Apply sensible defaults for skipped
questions and move to the next. The briefing must always run.

The agent already has signal from MCP detection (Slack `to:me`
results, calendar events, Drive docs). Use this data to auto-infer
and present confirmations — the user barely types.

## 2a. Workspace location

Silently run `pwd` to get the current directory path. Use the result as
the recommended path in the prompt below.

Use `AskUserQuestion`:
- "I'll save your config and rolling context here in [<result of pwd>].
  Is this the right workspace?"
- Options: "Yes, this is good" / "Let me pick a different folder"

If the user picks a different folder, ask (plain text) for the path,
then `cd` there for all subsequent file writes.

## 2b. Key collaborators (auto-inferred)

Silently scan available data:
- Slack: `to:me` search results → extract DM partners, @mentioners
- Calendar: today's events → extract 1:1 partners, frequent attendees
- Drive: recent docs → extract comment authors

Present top 3–5 names via `AskUserQuestion`:
- "These look like your key collaborators: [names]. Right?"
- Options: "Yes, looks right" / "Let me adjust"

## 2c. Slack channels and DM partners (auto-detected)

The `to:me` search reveals which channels AND DM partners the user
is active in. Two separate picks:

**Channels.** Top 3–5 by @mention / reply frequency. Skip
company-wide (10k+) and bot channels. Present via `AskUserQuestion`:
- "I'll scan these channels each morning: [list]. Good?"
- Options: "These look good" / "Let me pick different ones" /
  "Scan all my active channels"

**Resolve the channel list in this turn — do not defer.**

- If "These look good": save the suggested list. Done.
- If "Scan all my active channels": save `catch-all: true`. Done.
- If "Let me pick different ones": follow up IMMEDIATELY with ONE
  plain-text prompt — "Type the channels you want scanned,
  comma-separated, or `skip` to use DMs + @mentions only." Resolve
  each name to a channel ID via `slack_search_channels`, save the list.

Once saved, the channel config is **consumed**. Do NOT re-ask later.

**DM partners.** From `to:me` results, extract distinct `user_id`
values where conversation type is `im` (1:1) or `mpim` (group).
Rank by message volume in the last 7 days. Top 3–5. Present via
`AskUserQuestion`:
- "I'll scan DMs from these people by name, plus any DM or group-DM
  with activity in the last 24h (catch-all): [list]. Good?"
- Options: "These look good" / "Let me pick different ones" /
  "Only named partners (skip catch-all)" / "Don't scan DMs"

Save two sections to rolling context:
```markdown
### Slack Triage Channels
- #channel-name (ID: C0XXXXXXX)

### Slack Triage DMs
- catch-all: true
- @Display Name (ID: U0XXXXXXX)
```

If "Don't scan DMs": write `catch-all: false` and surface a warning
every run: "DM scanning disabled — you may miss direct asks."

## 2d. Workstreams (auto-suggested)

Infer from **recurring** calendar series only — events that appear
at least twice in the past 30 days. Also include project names from
multiple Drive doc titles or Slack channel topics.

Present 2–4 via `AskUserQuestion`:
- "Your active workstreams look like: [list]. Sound right?"
- Options: "Yes" / "Let me adjust"

## 2e. Scaffold rolling context

Use `AskUserQuestion`:
- "Save these as a rolling context file? Future briefings will track
  milestones and blockers."
- Options: "Yes, create it" / "Not now"

If yes, create `context/rolling-context.md` from confirmed data.

## 2f. Save config

Write `.preflight.md` with all confirmed preferences (people,
channels, workstreams, timezone, date format).

**CRITICAL: Once config is saved, proceed directly to Phase 3
(produce the briefing). Do NOT stop. Do NOT ask "ready?"**
