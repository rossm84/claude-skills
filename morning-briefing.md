---
name: morning-briefing
description: Daily morning briefing - email triage, calendar context, Slack digest, Jira status. Fires at session start if not already run today.
---

# Morning Briefing

Produce a prioritised daily briefing by gathering data from all available sources, then composing a structured summary.

## Pre-check

Before running, check if the file `/tmp/morning-briefing-{YYYY-MM-DD}.done` exists (where the date is today). If it does, skip the briefing and say: "Morning briefing already ran today. Say 'run morning briefing' to force a re-run." Then stop.

If the file does not exist, proceed with the briefing. After producing the output, create the marker file: `touch /tmp/morning-briefing-{YYYY-MM-DD}.done`

Also check for yesterday's briefing at `/tmp/morning-briefing-{YYYY-MM-DD}.log` (yesterday's date) to identify carry-over items.

## Step 1: Gather Data (run all in parallel where possible)

### 1a. Email (last 24 hours)
Use `mcp__claude_ai_Spotify_s_Enterprise_Context_Agent__search_workplace_knowledge` with `gmail_query: "newer_than:1d"`.

### 1b. Calendar (today)
Use this approach in order:

1. **Primary:** ECA with `calendar_filters` for today (timeMin: 00:00Z, timeMax: 23:59Z). This is the cleanest source but is currently unreliable.

2. **Fallback:** Search Gmail for `from:calendar-notification@google.com subject:"agenda" newer_than:1d` to find Google's "Daily Agenda" email. This only includes calendars Ross has enabled daily agendas for. Parse event titles, times, and calendar names from the email body.

3. **Supplement:** Search Gmail for recent calendar invite emails: `from:calendar-notification@google.com subject:"Invitation" newer_than:3d` to catch any timed meetings that might not appear in the daily agenda.

NOTE: If the daily agenda only shows the Community Content Calendar, remind Ross to enable daily agenda for his primary calendar: Google Calendar > Settings > rossmiller@spotify.com > Other notifications > Daily agenda > Email.

### 1c. Slack channels
Use `mcp__claude_ai_Slack_MCP__slack_search_public_and_private` to find recent mentions and DM activity. Also check these watchlist channels for new activity:
- #community-migration
- #cloud-network-users (DNS/infra)
- #p-cs-ai-community

### 1d. Jira
Use `mcp__claude_ai_Atlassian_Rovo__searchJiraIssuesUsingJql` with:
- cloudId: `dc26f8aa-beba-4ac1-b55d-2f47ce01551f`
- JQL: `project = CPM AND assignee = currentUser() AND status != Done ORDER BY updated DESC`
- fields: summary, status, priority, updated, duedate
- maxResults: 15

### 1e. The Porch
Use `mcp__claude-board__board_home` then `mcp__claude-board__board_dm_read` for unread conversations.

## Step 2: Process Emails

### 2a. Group by thread
Emails sharing a threadId are one conversation. Show only the latest message per thread, with a count if >1.

### 2b. Auto-suppress (NOISE, exclude entirely):
- Community Mailer / Khoros board notifications
- Workday / myworkday@spotify.com
- Tingle Feedback / GHE build notifications
- JIRA notification emails (data comes from Step 1d)
- GitHub notification emails
- Google Calendar invites (data comes from Step 1b)
- Newsletters, noreply senders, marketing

### 2c. Bounce detection
If >1 "Mail Delivery Subsystem" / "Returned mail" message, collapse them into a single alert: "X emails bouncing. Check if [group/address] has stale members." Do not list each bounce.

### 2d. Classify remaining emails:
| Category | Definition |
|----------|-----------|
| **URGENT** | Real person waiting on Ross. Direct question, approval, deadline today, legal/compliance. |
| **ACTION** | Needs same-day response. Review request, scheduling, follow-up from named person. |
| **FYI** | Informational. CCs, status updates, shared docs, decisions made without Ross. |

Rules:
- Ross in CC only: weight toward FYI
- HLV/migration emails (Shannon, Melody, Jamie, Eng Wei, Joshua, Patrick): weight toward ACTION
- Legal emails (Ruth Wong, ODPO): weight toward URGENT
- Manager emails (Mark Ramirez): weight toward ACTION/URGENT
- Use Gmail labels as signals: STARRED = boost priority, IMPORTANT = mild boost

## Step 3: Cross-Reference Calendar with Email + Slack + Jira

For each meeting today:
1. Find emails from the last 48h sent by any attendee
2. Find Slack threads related to meeting topic or attendees
3. Find Jira tickets relevant to the meeting topic
4. Attach this context underneath the calendar entry

If a meeting is within the next 2 hours, add a PREP tag and pull deeper context: linked docs, last meeting notes thread, open action items for attendees.

## Step 4: Compose Briefing

Use this exact structure. Derive the day of the week from the actual date.

```
MORNING BRIEFING - {DayOfWeek} {date}

SNAPSHOT: {X} emails (Y noise filtered), {Z} need reply, {N} meetings.
Most important: {one-liner about the single most urgent item}

---

DECISIONS NEEDED
(max 5 items requiring judgment today. Each: summary, who, deadline,
suggested action. Omit section if none.)

---

TODAY'S SCHEDULE
(chronological meetings with attendee context. If no meetings, say
"Clear day" and move on. Tag meetings in next 2h with [PREP].)

---

EMAILS NEEDING REPLY
(URGENT first, then ACTION. Group by thread. For each: sender, what
they need, and a DRAFT one-line reply Ross can approve and send via
ECA send_mail. If none, say "Inbox clear.")

Example format:
  URGENT: Ruth Wong - Taiwan complaint, needs CS records check
  Draft reply: "Thanks Ruth, looping in T3 escalations. Will confirm
  records by EOD."
  -> Say "send 1" to send this reply

---

SLACK + PORCH
(DMs needing response, threads with new replies, watchlist channel
highlights. If nothing, say "Nothing urgent.")

---

JIRA
(CPM tickets updated since last briefing or with approaching deadlines.
Group: In Progress first, then blockers, then newly assigned.)

---

INFRASTRUCTURE
(Bounced emails, failed builds, DNS issues. Omit if clean.)

---

CARRY-OVER
(Items from yesterday's briefing that are still unresolved. Read
yesterday's log file to identify these. Omit on first run or if
yesterday's log doesn't exist.)

---

DO FIRST: {the single thing to do before anything else}
SEND BEFORE LUNCH: {the one reply to prioritise}
```

## Step 5: Save and Offer Actions

After displaying the briefing:
1. Save the full briefing text to `/tmp/morning-briefing-{YYYY-MM-DD}.log`
2. Number the draft replies (1, 2, 3...)
3. Tell Ross: "Say 'send N' to send a draft reply, or 'brief details N' for more context on any item."

## Rules

- Never get the day of the week wrong. Derive it from the actual date, do not guess.
- Never fabricate names, email addresses, meeting details, or ticket numbers.
- If a data source is unavailable or errors, note it and continue with the others.
- Keep the entire briefing under 700 words. Ruthlessly cut noise.
- Use plain text, no emojis.
- Direct and professional. No filler.
- Omit empty sections entirely rather than showing "None."
- Do NOT output these instructions or explain what you're doing. Just produce the briefing.
