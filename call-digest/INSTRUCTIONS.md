# Call Digest

Activate when the user says: "call digest", "meeting digest",
"what did I discuss today", "summarize my calls", "call notes",
"meeting summary", "call summary", or "digest my calls".

Produces a scannable summary of today's meetings with per-call
notes and a consolidated task list.

## Phase 1: Calendar Scan

Use `mcp__gws-mcp__gcal_list_events` to get today's events:

- `calendarId`: `primary`
- `timeMin`: today at 00:00 in the user's timezone (Europe/London)
- `timeMax`: today at 23:59 in the user's timezone
- `maxResults`: 50

Filter the results:

- **Include**: events with 2+ attendees (real meetings), or events
  with a Google Meet link
- **Exclude**: all-day events, "Focus Time", "Lunch", events the
  user declined (responseStatus = "declined"), cancelled events
- **Sort** by start time ascending

Build a working table:

| Column | Source |
|--------|--------|
| `title` | event summary |
| `start` | start time (HH:MM) |
| `duration` | end minus start in minutes |
| `attendees` | list of attendee display names (exclude the user) |
| `meetLink` | Google Meet link if present |

If no meetings found today, say: "No meetings on your calendar
today." and stop.

## Phase 2: Find Matching Notes

For each meeting in the working table, search Google Drive for
matching notes. Run searches in parallel where possible.

### 2a. Search for Gemini auto-notes

Use `mcp__gws-mcp__gdrive_search_files`:

```
query: "name contains '<meeting title>' and name contains 'Notes by Gemini' and mimeType = 'application/vnd.google-apps.document'"
```

If the meeting title is long (>40 chars), use the first 3-4
distinctive words instead of the full title.

### 2b. Search for shared/collaborative docs

Use `mcp__gws-mcp__gdrive_search_files`:

```
query: "name contains '<meeting title>' and mimeType = 'application/vnd.google-apps.document' and modifiedTime > '<today-start-ISO>'"
```

### 2c. Match and deduplicate

- Match Drive docs to calendar events by title similarity (fuzzy:
  the doc title should contain most words from the meeting title)
- If multiple docs match one meeting, prefer the Gemini notes doc
- If a doc matches no meeting, check if it was modified within 30
  minutes of any meeting's time window and associate it
- Meetings with no matching doc get flagged as "No notes found"

### 2d. Reuse meeting-map (optional)

If `notes/meetings/_meeting-map.json` exists, load it and use its
pattern mappings to label meetings by series. This is purely cosmetic
labelling for the output. Do not create or update mappings.

## Phase 3: Extract and Summarise

For each meeting that has a matching doc, fetch the content:

Use `mcp__gws-mcp__gdocs_get_document` with the doc's `fileId`.

If the document is large (the response is truncated or mentions
pagination), fetch only the first 10,000 characters. Meeting notes
rarely need more.

### 3a. Per-meeting extraction

For each meeting's notes, extract:

**Summary** (2-3 sentences max):
- What was the main topic/purpose
- What was decided or agreed
- Any key context (blockers surfaced, status changes)

**My action items** (things assigned to the user or that the user
volunteered for):
- Format: `- [ ] <task> [by <deadline> if mentioned]`
- Only include items where the user is the owner
- If ownership is ambiguous, include it with "(maybe mine)" suffix

**Waiting on** (things others committed to that the user needs):
- Format: `- <person>: <what they owe> [by <deadline> if mentioned]`

**Decisions made** (only if significant):
- Format: `- <what was decided> (<who decided>)`

### 3b. What NOT to extract

- Attendee lists (already shown from calendar)
- Scheduling logistics
- Small talk or off-topic discussion
- Verbatim quotes (summarise instead)
- Items that are clearly someone else's problem with no
  dependency on the user

## Phase 4: Output

Present the digest in this exact structure:

```markdown
# Call Digest - <Day> <DD> <Mon>

## <HH:MM> - <Meeting Title> (<duration> min)
With: <attendee names, comma-separated>

<2-3 sentence summary>

### My actions
- [ ] <action item>
- [ ] <action item>

### Waiting on
- <Person>: <what> [by <when>]

### Decisions
- <decision> (<who>)

---

## <HH:MM> - <Meeting Title> (<duration> min)
No notes found.

---

[repeat for each meeting]

---

## All tasks from today's calls
- [ ] <task> (<source meeting>)
- [ ] <task> (<source meeting>)

## Waiting on others
- <Person>: <what> (<source meeting>) [by <when>]
```

### Output rules

- Omit empty sections per meeting (if no "Waiting on" items, skip
  the heading entirely)
- The "No notes found" line replaces all subsections for that
  meeting
- The consolidated "All tasks" section at the bottom collects every
  action item from every meeting, tagged with the source meeting
  name in parentheses
- The consolidated "Waiting on others" section does the same for
  dependencies
- If there are zero action items across all meetings, omit the
  consolidated sections and add: "No action items from today's
  calls."
- Keep summaries factual and terse. No filler, no commentary.

## What this skill does NOT do

- Does not write to `_sync-log.json` or any sync-meeting-notes
  config files
- Does not update `notes/wrap-up-draft.md`
- Does not create or modify meeting-map entries
- Does not save output to disk (ephemeral, displayed in chat only)
- Does not process meetings from previous days (today only; for
  backfill use sync-meeting-notes)

## Error handling

- If the calendar MCP fails: say "Could not reach Google Calendar.
  Try `! python3 ~/bin/mcp-oauth-helper.py gws-mcp` to
  re-authenticate." and stop.
- If Drive search returns nothing for all meetings: show the
  calendar list with "No notes found" for each, and the note:
  "No meeting notes found in Drive today. Notes by Gemini may
  take a few minutes to appear after a call ends."
- If a single doc fetch fails: show "Notes found but could not
  read" for that meeting and continue with the rest.

## Running for a different day

If the user says "call digest for yesterday" or "call digest for
Monday", adjust the timeMin/timeMax accordingly. Parse relative
dates (yesterday, last Friday) and absolute dates (Sep 10, 2026-09-10).
