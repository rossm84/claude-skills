# Preflight

## Quick install — paste into regular terminal window

**1.**
```bash
rm -rf /tmp/agent-skills && git clone git@ghe.spotify.net:agarland/agent-skills.git /tmp/agent-skills
```

Hit enter.

**2.**
```bash
cat /tmp/agent-skills/skills/preflight/claude/INSTRUCTIONS.md >> CLAUDE.md
```

---

Activate when the user says "preflight", "morning", "morning briefing", "start my
day", "what's on today", "daily briefing", "catch me up", "sunup", "sun up",
"sup", or "good morning".

**Note:** Claude Code may show "Error: Unknown skill: preflight" before
reading this file. That's normal — ignore it and proceed. Do not echo
or reference this error in your output.

Daily briefing that adapts to available data sources. Tracks handled
items between runs so the same threads don't resurface. First run
delivers value immediately; subsequent runs get richer as preferences
are saved.

## Session title

The first heading of the output **must** be `# SunUp — [Day of Week], [Mon] [Day]`
(e.g. `# SunUp — Friday, Apr 24`). Full day name, 3-letter month abbreviation, day
number with no leading zero, no year, no slashes. When launched from the CLI, use
`claude --name "SunUp — Friday, Apr 24"` (substituting today's date) for a clean
session list.

## Output discipline

Suppress all reasoning, calculations, and planning from output. Produce
ONLY the formatted briefing sections.

### Recovery Rule (if you get off-track)

**If at any point you find yourself doing ANY of these, you are off-track:**
- Narrating your reasoning, MCP-call planning, or timestamp math in the output
- Displaying raw `fileId`s, channel IDs, or Slack permalinks as briefing content
- Asking the user to paste something an MCP can fetch
- Swallowing MCP errors instead of surfacing them with a next step
- Rendering the briefing before the silent User Feedback read has completed
- Asserting someone's current presence (see Language constraints)
- Using emojis anywhere in briefing output (plain text and markdown only)

**STOP. Reset.** Read state silently, gather sources in parallel, produce
ONLY the formatted sections.

## Language constraints

**Availability inference (strict).** Never assert someone's current
presence or online state. You work from historical Slack / Drive /
Calendar signals, not a real-time presence API.

- Prefer past tense with a time qualifier: `"[colleague] was active 2h
  ago"` / `"[colleague] last posted yesterday morning"`
- Never write: `"[colleague] is online today"` / `"[colleague] is
  available now"` — nothing implying live presence.
- Ground timing suggestions in observed signal, not asserted presence.

Applies to every section — Action needed, Suggestions, FYI,
meeting prep, reply drafts, follow-up prompts.

## When to use

Trigger phrases: "preflight", "morning briefing", "start my day",
"daily briefing", "catch me up", "good morning". Not for mid-day
status checks, single-channel Slack lookups, or repeat runs in the
same session.

Use `AskUserQuestion` for all yes/no and selection decisions during
setup. Reserve plain-text prompting for open-ended questions only.

## Prerequisites

- At least one MCP connected (Slack, Google Calendar, or Google Drive).
- `.preflight.md` config file in workspace root (auto-created on first run).

---

## State tracking

See [reference/state-format.md](reference/state-format.md) for the state
file format, filtering rules, and TTL behavior.

---

## Phase 1: Detect and connect (first run) / Detect (repeat run)

### 1a. First-run opening message

If `.preflight.md` does not exist (first run), output this message
**before** doing anything else:

> "Hey — first run, so I'm taking a minute to get you set up. I'll
> wire up your calendar, Slack, and meeting docs, save your preferences,
> and then run your first briefing. After today, just say 'preflight'
> and you'll be in under 30 seconds."

Then proceed silently.

### 1b. Silent detection

Perform silently — no output.

**MCP servers:** test each with a lightweight call:
- **Slack** — `slack_search_channels` ("general", limit 1)
- **Google Calendar** — `list_calendar_events` (today, max 1)
- **Google Drive** — `list_drive_files` ("Notes by Gemini", max 1)

Record responses. Do not retry failures.

**Config file:** check for `.preflight.md` in workspace root.
Found → apply stored config, skip to Phase 3 (produce briefing).
Not found → first run, continue to 1c.

**Local files:** check for rolling context (`context/rolling-context.md`,
`rolling-context.md`, `STATUS.md`), wrap-up draft, state file. Record.
Do not create.

**Timezone:** `date +%Z`. Fall back to calendar event timezone. UTC
as last resort.

**Date format:** Infer from timezone. US timezones (EST, EDT, CST,
CDT, MST, MDT, PST, PDT, AKST, AKDT, HST) → MM/DD/YY.
All others → DD/MM/YY. Store in config as `date_format`.

### 1c. First-run MCP onboarding (skip if config file exists)

See [reference/zero-mcp-setup.md](reference/zero-mcp-setup.md) for the
full onboarding flow, priority order, MCP Gateway URLs, and Claude Code
setup commands.

---

## Phase 2: First-run interview (skip if config exists)

See [reference/first-run-interview.md](reference/first-run-interview.md)
for the full interview flow (workspace location, collaborators, Slack
channels, DM partners, workstreams, rolling context scaffold, config save).

---

## Phase 3: Produce the briefing

Run available sources in parallel, combine into one output. Use
config from Phase 2 (first run) or `.preflight.md` (repeat run).
Omit sections for unavailable sources — list in footer.

### Step 0: Staleness check (companion-skill hook)

Before the data-gathering steps, `stat` the mtimes of two companion-skill
outputs:

- `context/rolling-context.md`
- `notes/wrap-up-draft.md`

If either file exists AND its mtime is more than **24 hours** old, compute the
age in days (round down) and hold the staleness signal in memory (24h matches
the briefing's own lookback window — if the source file didn't move in a day,
the briefing is derived from stale context). It will be rendered as a one-line
`## Heads up` nudge at the bottom of the briefing (see Output Format).

If either file doesn't exist, silently skip — don't nudge the user about a file
they've chosen not to maintain. Only nudge on stale files, never missing ones.

This check fires only once per briefing and has no effect on the core data
flow. It exists to keep the wrap-up → Preflight pipeline healthy.

### Step 0b: MCP health check (run before all data-gathering steps)

Ping each data-source MCP with a lightweight call. Run all three in parallel.

| MCP | Health call |
|---|---|
| Google Calendar | `list_calendar_events` with today's date, `max_results: 1` |
| Slack | `slack_read_user_profile` with no arguments |
| Google Drive | `list_drive_files` with `maxResults: 1`, empty query |

**If any call fails or returns "Not connected":** stop the briefing
immediately and output a single consolidated block — do NOT proceed to
Steps 1–5 with broken MCPs:

```
## MCP Health Check — action required before briefing

- Slack: NOT CONNECTED — re-auth at backstage.spotify.net/mcp-explorer/link/slack-mcp
- Google Drive: NOT CONNECTED — re-auth at backstage.spotify.net/mcp-explorer/link/google-drive-mcp
- Google Calendar: OK

Fix the above, then say "preflight" again to run the full briefing.
```

**If all three respond successfully:** proceed silently to Step 1. Do not
mention the health check in the briefing output.

### Step 1: Calendar

```
list_calendar_events
  date: "<today as YYYY-MM-DD>"
  max_results: 7
```

If the response includes `"truncated": true`, append under the calendar table:
`> Calendar showing first 7 events — check calendar directly for any later meetings.`

Extract per event: time (local), title, attendees, linked docs.
Highlight key people from config.
Extract Google Doc IDs from event descriptions — pass to Step 3.

Flag meetings needing prep: 1:1s, reviews, planning, user-organized.
Identify focus windows (gaps ≥ 30 min).

### Step 2: Slack triage

Scan three sources — channels, named DM partners, catch-all recent
DM activity. Missing a group DM where the user is addressed by first
name (not @mention) is the known highest-trust-cost failure mode
this step exists to prevent.

**Resolve the user's own ID and first name once per run** via
`slack_read_user_profile` (no `user_id` returns caller's profile).
Store `my_user_id` and `first_name`.

**Always scan:**
1. **Saved channels** — all configured channels.
2. **Named DM partners** — from `### Slack Triage DMs` in rolling
   context, call `slack_read_channel` with each partner's `user_id`
   as `channel_id`.
3. **Catch-all DM sweep** — `slack_search_public_and_private` with
   `query: "to:me after:<YYYY-MM-DD>"` (24h / 72h Mondays). Extract
   unique `channel_id` values where type is `im` or `mpim`. Dedupe
   against named partners, then `slack_read_channel` each.
4. **@mention backstop** — `to:me` also surfaces @mentions in
   channels the user isn't in. Include those.

Only skip a DM source if the user explicitly says "only named
partners" or "don't scan DMs" — **never skip silently**. If
`slack_read_channel` on a DM returns a permission error, surface it
explicitly (OAuth scope `im:history`/`mpim:history` likely missing).

Per channel/DM: read last 24h (72h Mondays), max 50 messages. Read
threads on any message with `reply_count > 0`.

**Before classifying a thread, check if the user already replied.**
Read thread replies and check whether any is from `my_user_id`. If
yes, classify as **Handled** and skip. Count handled and report
"Inbox clear on N threads" (omit if zero).

**Per message extract:** author, timestamp, 1-2 sentence preview,
reply count, conversation type (`channel`/`im`/`mpim`), whether
`my_user_id` is @mentioned, whether `first_name` appears in the
first two lines (regex `\b<first_name>\b` case-insensitive,
excluding URLs / code blocks / `@<first_name>` usernames), whether
user has previously posted in the thread.

**Classify into three buckets.** Action needed and Suggestions
are separate tracks — never mix. Any single Action-needed match
promotes immediately (OR, not AND).

- **Action needed:**
  - @mentioned
  - **Addressed by first name** in the body
  - **Any unreplied DM or group-DM message** (read thread before
    classifying if `reply_count > 0`)
  - **Direct ask in a thread where the user previously posted**
    (latest message has `?` or "can you" / "could you" / "please")
  - Review request, deadline, blocker
  - User has NOT already replied
- **Suggestions (agent synthesis — cap 3):** cross-signal inferences.
  Every item must cite signals. Low confidence = omit.
- **FYI** — update, decision, announcement
- **Skip** — noise, chatter, bot messages, already replied

When surfacing a DM item, append a short reason (`— addressed by
name`, `— unreplied DM`, `— direct ask in thread`).

**Deduplication:** If an action item appears in both Slack Triage
and Google Doc Action Items (same person, same topic), show once.
Slack source wins.

Filter out threads in `.preflight-state.md` `Handled Slack Items`.

### Step 3: Google Doc action items

**Classification rules:** An extracted line qualifies ONLY if it meets ALL three:

1. **Structure** — verb-initial imperative OR subject + future verb.
2. **Tense** — future or imperative. SKIP past-tense descriptive.
3. **Source** — prefer explicit `## Action items` / `## Next steps`.

**If a doc has no explicit action section, surface ZERO items.**

**Anti-patterns (always skip):** events, decisions, observations.

Gather docs from three sources:
1. **"Notes by Gemini"** — last 7 days
2. **Calendar-linked docs** — IDs from Step 1 (highest signal)
3. **User-authored "notes" docs** — last 7 days, excluding Gemini

Deduplicate by doc ID. Skip docs matching `Scanned Docs` in state.

Per doc:
1. Fetch structure via `get_document_structure` (stripImages: true).
   Fallback to `get_document_preview` on failure.
2. Parse unchecked items matching recipient's name.
3. Fetch unresolved comments — surface @mentions and action language.
4. Apply Resolution check and Ownership filter below.

**Ownership filter:**
1. **Keep:** user is the named actor.
2. **Downgrade to FYI:** dependency blocking user, someone else owns.
3. **Drop:** user has no role. If uncertain, default to Drop.

**Resolution check (against rolling context):**
1. **Clear resolution signal → DROP entirely.** ("approved", "shipped",
   "resolved", "superseded by", "descoped", etc.)
2. **Ambiguous → FYI** with `(status may have changed)`. In-progress
   language is NOT a resolution signal.
3. **Already tracked `[ ]`, no resolution → surface** with `(already tracked)`.
4. **No mention in rolling context → surface normally.**

**Date-ordering rule (Case 1):** requires BOTH a resolution signal AND
a date postdating the source doc's `modifiedTime`.

### Step 4: Rolling context

**Source-of-truth rule:** Rolling-context is ground truth. If it
conflicts with a meeting note, use rolling-context only.

**Blockers** (show first): flagged as blocked/waiting/stalled. Max 3.

**Upcoming Milestones** (show second): items within 7 days. Max 3.

### Step 5: Wrap-up draft

Count pending entries by section. Report totals. Skip if empty/absent.

---

## Output format

See [reference/output-format.md](reference/output-format.md) for the full
template, key rules, staleness nudge rendering, Phase 4 follow-up logic,
Slack reply drafting, item dismissal, state file write-back, and the
feedback loop.

## Known gotchas

See [reference/known-gotchas.md](reference/known-gotchas.md) for error
handling, known gotchas, and success indicators.

## Extend this skill

Preflight pulls from multiple sources and renders one briefing. You can
hook in an additional source:

1. Write a skill or script that produces a small artifact — JSON, markdown,
   or a file under `notes/` — on a known path and schedule.
2. Add a new Step in Phase 3 that reads that artifact. Use a cheap `stat`
   check first and skip silently if the file is missing or older than your
   freshness threshold.
3. Declare any new MCP tools needed.
4. Render a new section in the Output Format with the data. Follow the
   "Nothing to report" convention so the user knows it was checked.

**Example:** a `metrics-daily` skill that drops a JSON file at 7 AM;
Preflight reads it and renders a "KPI pulse" section above Blockers.
