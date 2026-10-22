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

- At least one MCP connected: Slack, or Google Workspace (`gws-mcp`).
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
- **Google Workspace (`gws-mcp`)** — `execute_tool` name `gcal.list_events` (today, max 1)

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

Ping Slack and Google Workspace with a lightweight call. Run both in parallel.

| MCP | Health call |
|---|---|
| Slack | `slack_read_user_profile` with no arguments |
| Google Workspace | `execute_tool` name `gcal.list_events`, today, `max_results: 1` |

**If any call fails or returns "Not connected":** stop the briefing
immediately and output a single consolidated block — do NOT proceed to
Steps 1–5 with broken MCPs:

```
## MCP Health Check — action required before briefing

- Slack: NOT CONNECTED — re-auth at backstage.spotify.net/mcp-explorer/link/slack-mcp
- Google Workspace: NOT CONNECTED — re-auth at backstage.spotify.net/mcp-explorer/link/gws-mcp

Fix the above, then say "preflight" again to run the full briefing.
```

**If both respond successfully:** proceed silently to Step 1. Do not
mention the health check in the briefing output.

### Step 1: Calendar

```
execute_tool on user-gws-mcp
name: "gcal.list_events"
args:
  time_min: "<today>T00:00:00"
  time_max: "<today>T23:59:59"
  timezone: "<IANA timezone from Phase 1>"
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
5. **Full notifications sweep (Ross, 22 Oct 2026: "all notifications, then look in the channel where it was raised").**
   Not just @mentions: everything that would land in his Slack Activity feed for the window, received AND sent:
   - @mentions of him, and @here / @channel / group handles (e.g. @community-team) in channels he's in.
   - New replies in threads he started or replied to in the last 7 days (re-read each of those threads).
   - Every DM and group DM with activity in the window, including app/bot DMs (Jira, Google Drive/Calendar,
     GitHub/GHE, Workday, Groove…).
   - Keyword highlights and reactions on his messages, where the tools expose them.
   For **each notification, open the source** (`slack_read_thread` for threads, `slack_read_channel` around the ts
   for channel posts) and read the surrounding conversation before classifying it. Classify as **needs Ross**
   (who, channel, the ask, link), **FYI**, or **already answered** (use the sent-message sweep below).

Only skip a DM source if the user explicitly says "only named
partners" or "don't scan DMs" — **never skip silently**. If
`slack_read_channel` on a DM returns a permission error, surface it
explicitly (OAuth scope `im:history`/`mpim:history` likely missing).

Per channel/DM: read last 24h (72h Mondays), max 50 messages. Read
threads on any message with `reply_count > 0`.

**Sent-message sweep (required, before classifying anything).** Run
`slack_search_public_and_private` with `filters: "from:<@my_user_id> after:<YYYY-MM-DD>"`,
`sort: timestamp`, and **follow `cursor` through every page** until
"End of results". Never stop at the first 20. Build a set of
conversations/threads Ross posted in, and the time of his latest message in each. A DM or
thread counts as **Handled** if Ross's latest message is newer than the other person's.
If a lookup can't confirm it (e.g. name filter returns nothing), read
the DM with `slack_read_channel` instead of guessing. Never mark an item
unreplied without this check.

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


## Extra checks (Ross, 22 Oct 2026: "do that entire list")

Run these alongside the Slack/Gmail/calendar steps (in parallel where possible). Each feeds the open items and
reminder candidates. Keep each to a few lines in the output; skip a section with nothing in it. If a source can't be
reached (e.g. headless runs without that connector), say "not checked" for it, never guess.

1. **Setlist health** (`~/community-tools`; gcloud as rossmiller@spotify.com, project spotify-community):
   - Live version: `curl -s https://spotify-community.web.app/nsacm/changelog.json` (top release).
   - Errors and slow requests since the last run: `gcloud logging read` on `resource.type="gae_app"`,
     `module_id="community-export"` request_log; report 5xx count and the p90 of user-facing `/api/nsacm/*`
     routes (exclude cron: tick, poll, spam/live, premod/attack, health-check). Flag any route with p90 > 5 s.
   - Overnight (SunUp) or today (SunDown): Missed posts, the coverage check result, and any spam attack
     (Firestore `nsacm_meta/spam_attack` `active`, or the coverage email in Gmail).
   - SunDown also: posts closed today and anything still waiting past its reply target, if the Reports API or
     the coverage email shows it.
2. **PRs, reviews and agents:** `gh pr list --repo community-platform/community-tools --state open` (and
   `--author @me`); for each, the latest Xirp verdict (issues waiting on Ross, or clean and ready to merge).
   Honk sessions: `list_honk_sessions` / `get_honk_session` for sessions that finished or failed since the last run.
   Failed deploys or CI checks on master.
3. **Jira and Groove:** Jira issues assigned to Ross or updated since the last run (Atlassian MCP
   `searchJiraIssuesUsingJql`, e.g. `assignee = currentUser() AND updated >= -1d`), plus S4D/DoD health updates due
   this week in Groove and any blockers.
4. **Community site:** HLV and community.spotify.com up (curl the homepage and an API path, status 200), certificate
   expiry (`echo | openssl s_client -connect community.spotify.com:443 2>/dev/null | openssl x509 -noout -enddate`;
   flag under 30 days), and Ongoing Issues that changed (HLV API, category Ongoing Issues).
5. **People:** who on the Community team and close collaborators is off today or tomorrow (calendar OOO events,
   Slack status), and birthdays or work anniversaries if Bandmanager exposes them.
6. **Meeting prep (SunDown for tomorrow, SunUp for today):** for each meeting, the last notes with those people
   (Drive "Notes by Gemini" / `notes/meetings/`) and any open actions Ross owns from them, one line each.
7. **Costs (weekly, Mondays, or when asked):** open Cloud Billing reports for project spotify-community in Ross's
   Chrome (billing account 01EB05-B1778F-D20612, read-only) and report month-to-date, forecast and any jump over 25%.
8. **Follow-ups owed to Ross:** things others promised him (Slack/Gmail/meeting notes: "I'll send…", "by Friday")
   that are now overdue, with who and where.

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

Search with `execute_tool` name `gdrive.search_files`
(`file_type: "document"`, `max_results: 10`).

Per doc:
1. `execute_tool` name `gdocs.get_document`, `document_id` = the file id.
   One call returns the full doc. If it fails, `gdrive.read_file` with
   `file_id`.
2. Parse unchecked items matching recipient's name.
3. Comments: `execute_tool` name `gdrive.list_comments`, `file_id`.
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

### Step 6: Reminder candidates (calendar)

Scan the Slack, Gmail and meeting-note items already gathered for
**dated commitments**: someone gives a deadline ("by Nov 3rd"), Ross
agrees to deliver something later ("I'll pull it once it's back up"),
or a follow-up date is set ("after wellness week", "until Oct 30").

For each, propose a reminder: title (`Reminder: <verb> <thing> for <person>`),
date/time (a 30-min slot before the stated deadline, working hours, Europe/London,
avoiding existing meetings), and a description with the source link.
Skip anything already on the calendar (check with `gcal.list_events`
across the date) or already done.

Render as a numbered `### Step 6: Reminders to add` list. **Never create
without approval.** When Ross says "add N" / "add all", create each with
`gcal.create_event` on his primary calendar, no attendees, a popup
reminder, then confirm with the event link. Record created reminders
in the state file so they're not proposed again.

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
