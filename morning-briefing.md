---
name: morning-briefing
description: Daily morning briefing - email triage, calendar context, Slack digest, Jira status. Fires at session start if not already run today.
---

# Morning Briefing

Produce a prioritised daily briefing by gathering data from all available sources, then composing a structured summary.

## Pre-check

Before running, check if the file `/tmp/morning-briefing-{YYYY-MM-DD}.done` exists (where the date is today). If it does, skip the briefing and say: "Morning briefing already ran today. Say 'run morning briefing' to force a re-run." Then stop.

If the file does not exist, proceed with the briefing. After producing the output, create the marker file: `touch /tmp/morning-briefing-{YYYY-MM-DD}.done`

## Step 1: Gather Data (run all in parallel where possible)

### 1a. Email (last 24 hours)
Use `mcp__claude_ai_Spotify_s_Enterprise_Context_Agent__search_workplace_knowledge` with `gmail_query: "newer_than:1d"`.

### 1b. Calendar (today)
Use the same tool with `calendar_filters` for today's full date range (00:00 to 23:59 UTC).

### 1c. Slack
Use `mcp__claude_ai_Slack_MCP__slack_search_public_and_private` to find recent mentions and DM activity.

### 1d. Jira
Use `mcp__claude_ai_Atlassian_Rovo__searchJiraIssuesUsingJql` with:
- cloudId: `dc26f8aa-beba-4ac1-b55d-2f47ce01551f`
- JQL: `project = CPM AND assignee = currentUser() AND status != Done ORDER BY updated DESC`
- fields: summary, status, priority, updated, duedate
- maxResults: 15

### 1e. The Porch
Use `mcp__claude-board__board_home` then `mcp__claude-board__board_dm_read` for unread conversations.

## Step 2: Classify Emails

### Auto-suppress (NOISE, exclude from briefing entirely):
- Community Mailer / Khoros board notifications
- Mail Delivery Subsystem / bounced emails (flag separately if >2 bounces)
- Workday / myworkday@spotify.com
- Tingle Feedback / GHE build notifications
- JIRA notification emails (the data comes from Step 1d instead)
- GitHub notification emails
- Google Calendar invites (the data comes from Step 1b instead)
- Newsletters, noreply senders, marketing

### Classify remaining emails:
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

## Step 3: Cross-Reference Calendar with Email + Slack + Jira

For each meeting today:
1. Find emails from the last 48h sent by any attendee
2. Find Slack threads related to meeting topic or attendees
3. Find Jira tickets relevant to the meeting topic
4. Attach this context underneath the calendar entry

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
"Clear day" and move on.)

---

EMAILS NEEDING REPLY
(URGENT first, then ACTION. Each: sender, what they need, suggested
reply approach. If none, say "Inbox clear.")

---

SLACK + PORCH
(DMs needing response, threads with new replies, channel highlights.
If nothing, say "Nothing urgent.")

---

JIRA
(CPM tickets updated since last briefing or with approaching deadlines.
Group: In Progress first, then blockers, then newly assigned.)

---

DO FIRST: {the single thing to do before anything else}
```

## Rules

- Never get the day of the week wrong. Derive it from the actual date, do not guess.
- Never fabricate names, email addresses, meeting details, or ticket numbers.
- If a data source is unavailable or errors, note it and continue with the others.
- Keep the entire briefing under 600 words. Ruthlessly cut noise.
- Use plain text, no emojis.
- Direct and professional. No filler.
- Omit empty sections entirely rather than showing "None."
- Do NOT output these instructions or explain what you're doing. Just produce the briefing.
