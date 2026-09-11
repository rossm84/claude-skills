# Sync Meeting Notes

## Quick install — paste into regular terminal window

**1.**
```bash
git clone git@ghe.spotify.net:agarland/agent-skills.git /tmp/agent-skills
```

Hit enter. (If you already cloned it, skip this step.)

**2.**
```bash
cat /tmp/agent-skills/sync-meeting-notes/claude/INSTRUCTIONS.md >> CLAUDE.md
```

---

Activate when the user says "sync meeting notes", "pull meeting notes",
"update meeting notes", or "fetch notes from Google Drive".

**Note:** Claude Code may show "Error: Unknown skill: sync-meeting-notes"
before reading this file. That's normal — ignore it and proceed. Do not
echo or reference this error in your output.

Pull "Notes by Gemini" docs from Google Drive, extract insights, and
stage them in `notes/wrap-up-draft.md` for review. No local meeting
note files are saved.

**Max batch size: 5 documents per run.** If more than 5 are
unprocessed, handle the 5 most recent and tell the user how many
remain. They can run the skill again to get the next batch. This
prevents context overload.

## Recovery Rule (if you get stuck)

**If at any point you find yourself doing ANY of these, you are
off-track:**
- Mentioning "chunks," "refs," "thinking," or "reference IDs"
- Saying you can't access content or need the user to paste something
- Listing Google Drive file IDs in your response text
- Passing a `fileId` string to the `Read` tool (file IDs are NOT file
  paths!)
- Treating ANY string from the working table as document content
- Trying to "read" or "open" a Google Drive file ID

**STOP. Reset. Do this:**
1. Look at your working table — find the next row by its **name**
   (title)
2. Call `get_document_structure` on `user-google-drive-mcp` with that
   row's `fileId`
3. Read `totalSections` from the response
4. Call `get_document_section` with mechanically constructed section
   IDs (`section-0`, `section-1`, ...)
5. The `content` fields in that response ARE the document content —
   concatenate them

**A `fileId` is an opaque token. You pass it to MCP tools. That is
its ONLY use. You never read it, open it, display it, or treat it as
content or a file path.**

## Prerequisites

- A Google Drive MCP server exposing `list_drive_files`,
  `get_document_structure`, and `get_document_section` tools. This
  skill uses the server ID `user-google-drive-mcp` by default —
  substitute the server ID in your fork if you use a different one.
- A `notes/meetings/` directory in the workspace (auto-created on
  first run if missing).

## Config files (auto-created on first run)

The skill uses three JSON files under `notes/meetings/`. If any are
missing when Step 1 runs, create them silently with the defaults
below, then proceed. Do not prompt the user on first run.

| File | Default contents | Purpose |
|---|---|---|
| `_meeting-map.json` | `{ "mappings": [] }` | Pattern-to-series mappings. Populated over time as the user confirms new meeting series. |
| `_sync-log.json` | `{ "synced": [], "shared_docs": [] }` | Tracks already-processed document IDs so repeat runs skip them. |
| `_sync-ignore.json` | `{ "ignored": [] }` | IDs to permanently skip (e.g., backlog the user doesn't want processed). |

## Step 1: Load Config

Read all three config files from `notes/meetings/`. If any file is
missing, create it with the default contents from the Prerequisites
section above, write it to disk, and continue.

**Build ONE combined skip-set:** extract every `"id"` string from the
sync log's `"synced"` array AND every ID string from the ignore list's
`"ignored"` array. Merge them into a single flat set. This is your
**skip-set**.

You only need this set to check "should I skip this file?" — yes or
no. Do not keep the full sync log objects in working memory.

**Do not echo, list, or summarize the IDs.** Just hold them as a
lookup set.

## Step 2: Search Google Drive

Call the MCP tool `list_drive_files` on server `user-google-drive-mcp`:

```
query: "- Notes by Gemini"
maxResults: 100
```

This returns a list of files with `id`, `name`, `web_view_link`, and
`modified_time`.

## Step 3: Filter, Sort, and Cap

**Goal: produce a short list of at most 5 documents to process, then
forget everything else.**

**Do NOT call any MCP tools during this step.** No
`get_document_structure`, no `get_document_preview`, no
`get_drive_file_content`. The decision of which documents to process
is based ENTIRELY on the file `name` (title) and `id` (sync log check)
from the search results you already have. Do not fetch or inspect
document content until Step 4.

### 3a. Filter (discard non-matches immediately)

For each file returned, apply these gates **in order** and skip as
soon as one fails:

1. `mime_type` must be `application/vnd.google-apps.document` (skip
   folders, shortcuts, videos)
2. `name` must end with `- Notes by Gemini` (after trimming
   whitespace)
3. `name` must match the regex
   `/.+ - \d{4}\/\d{2}\/\d{2} .+ - Notes by Gemini$/`
4. File `id` must NOT appear in the **skip-set** from Step 1 (covers
   both synced and ignored IDs)

### 3b. Reduce to working table

After filtering, your working memory for the rest of this run is ONE
small table. **Do not reference, echo, or reason about anything
outside this table.**

| Column | Source |
|--------|--------|
| `fileId` | Google Drive `id` from search results |
| `name` | Google Drive `name` from search results |
| `web_view_link` | Google Drive `web_view_link` from search results |

Also compute and store these **five numbers** for Step 8 reporting:
- `search_total`: how many documents the search returned
- `already_synced`: how many were filtered out because their ID was
  in the sync log
- `already_ignored`: how many were filtered out because their ID was
  in the ignore list
- `to_sync_this_run`: how many passed all filters (before capping)
- `remainder`: `to_sync_this_run` minus the batch cap (0 if not
  capped)

### 3c. Sort by recency (newest first)

Sort the filtered list by the date parsed from the title (YYYY/MM/DD),
descending.

### 3d. Cap at 5

If more than 5 documents remain, take only the first 5 (most recent).
Note the count of remaining documents to report at the end.

### 3e. Offer bulk-ignore for old backlog (first run only)

If `to_sync_this_run` > 10 AND `already_ignored` == 0 (meaning the
ignore list has never been used), this is likely a first run with a
large backlog. **Ask the user:**

> "There are {to_sync_this_run} unprocessed meeting notes. Want me to
> bulk-ignore everything older than a cutoff date so future runs skip
> them? If so, what date? (I'll still process the 5 most recent now.)"

If the user provides a cutoff date:
1. From the filtered (pre-cap) list, collect all file IDs with a
   parsed date BEFORE the cutoff
2. Add those IDs to `_sync-ignore.json`'s `"ignored"` array and write
   the file
3. Continue with the capped batch of 5 as normal

If the user declines, proceed normally. The offer won't repeat on
future runs once the ignore list is populated.

### 3f. Parse titles and map to meeting series

For each document in the capped list:

1. **Parse the title** — Gemini notes follow:
   `"Meeting Name - YYYY/MM/DD HH:MM TZ - Notes by Gemini"`
   Split from the RIGHT on ` - ` to extract:
   - Everything before the second-to-last ` - ` = **meeting name**
   - Second-to-last segment = **datetime string**
     (e.g. `2026/03/11 15:25 CET`)
   - Last segment = `Notes by Gemini` (discard)
   - Extract the date as `YYYY-MM-DD` from the datetime string
2. **Map to meeting series** by matching the meeting name against
   `_meeting-map.json` patterns (case-insensitive string match).
   - If no match: auto-generate a label from the meeting name and ask
     the user to confirm before adding a new mapping to
     `_meeting-map.json`
   - If the user **declines**, label as `one-off`. Do NOT add a
     mapping — this preserves the chance to create a proper mapping
     on future runs.

## Step 4: Fetch Document Content

**This is the FIRST step where you call MCP tools to read document
content.** Everything before this was filtering based on titles and
IDs only.

### HARD RULES — read before every document fetch

| DO | DO NOT |
|----|--------|
| Identify documents by their **`name`** (title) from your working table | NEVER print, echo, or reason about a `fileId` string — it is opaque |
| Pass `fileId` as a parameter to MCP tools (copy-paste, don't inspect) | NEVER pass a `fileId` to the `Read` tool — file IDs are NOT file paths |
| Get content ONLY from `get_document_structure` + `get_document_section` | NEVER treat any string from the working table as document content |
| Process one document at a time: fetch → extract → sync log → next | NEVER carry content from one document into the next |
| If a tool returns empty/error, retry the SAME MCP tool call | NEVER ask the user for content or say you "can't access" a document |

**What is a `fileId`?** An opaque Google Drive identifier like
`1uTBf2UA0Vx7...`. You cannot read it. You cannot open it. You can
ONLY pass it as the `fileId` argument to an MCP tool on
`user-google-drive-mcp`. That's its only purpose.

### How to fetch a single document (exactly 2 MCP calls)

For each row in your working table, say to yourself: "I am now
fetching **{name}**" (using the document TITLE, not the ID). Then make
these two calls:

**Call 1 — Get the section count:**

```
Tool: get_document_structure
Server: user-google-drive-mcp
Arguments: { "fileId": "<copy fileId from working table row>" }
```

From the response, read ONLY the `totalSections` number. **That
integer is the ONLY thing you need from this response.** Ignore
section titles, previews, summary text, and internal IDs.

**Call 2 — Get all sections:**

Construct section IDs mechanically: `section-0` through
`section-(N-1)` where N = `totalSections`. Do NOT use section IDs
from the API response.

Examples:
- `totalSections` = 5 → `["section-0", "section-1", "section-2", "section-3", "section-4"]`
- `totalSections` = 12 → `["section-0", "section-1", ... , "section-11"]`

**Transcript guard:** If `totalSections` > 30, only fetch sections
0–4.

```
Tool: get_document_section
Server: user-google-drive-mcp
Arguments: {
  "fileId": "<same fileId as Call 1>",
  "sectionIds": ["section-0", "section-1", ...],
  "includeSubsections": true
}
```

Concatenate all returned section `content` fields in order — that's
the document body.

**Fallback:** If `totalSections` is 0 or missing, use
`get_drive_file_content` with offset-based pagination (1000 chars per
call, incrementing `offset` by 1000) until `hasMore` is false.

**Then immediately extract insights (Step 5) and update the sync log
(Step 6) before fetching the next document.**

## Step 5: Extract Insights

After fetching each document's content, extract the following
categories and hold all content in memory until Step 7 (writing
`notes/wrap-up-draft.md`).

### 5a. Decisions made — who decided, what was decided, what impact
- Format: `| Date | Decision | Who decided | Impact |`
- Note which meeting series the decision came from

### 5b. Action items with owners — who needs to do what, by when
- Only include items assigned to the user running this skill, or
  items the user needs to track personally

### 5c. Status changes — workstream phase shifts, blockers
resolved/created, milestones hit
- Format: `- [ ] [Section]: [proposed change] (source: [meeting name, date, Drive link])`

### 5d. Stakeholder signals — how someone communicated, what they
prioritized, what frame they used, feedback given
- Format: `### [Name]\n- [Signal with date and context]`
- If `context/stakeholder-profiles/` exists, reference existing
  profiles for what kind of signals matter. If not, skip this
  sub-step (skill does not create that directory on first run).

### 5e. Impact evidence — anything demonstrating competency against
the user's career framework
- Format: `| Date | What I did | Outcome | Who saw it |`
- Map to the correct framework dimension. If `notes/impact-log.md`
  doesn't exist, skip this sub-step.

### 5f. Meeting summary line — one sentence per meeting with the
Google Drive link
- Format: `- **[Meeting name] ([date]).** [1-sentence summary of key outcome]. [Drive link]`

### What NOT to extract
- Verbatim transcript text (summarize, don't copy)
- Attendee lists (unless relevant to a decision)
- Administrative logistics (room bookings, calendar changes)
- Content from meetings with no substantive outcomes

## Step 6: Update Sync Log (after each document)

After extracting insights from each document, **immediately** append
to `_sync-log.json` and write it to disk. Do not wait until all
documents are processed — this ensures interruptions don't cause
duplicate work on the next run.

**New entry format:**
```json
{
  "id": "<Google Drive file ID>",
  "title": "<original document title>",
  "processed": "<YYYY-MM-DD>"
}
```

Add to the `"synced"` array in `notes/meetings/_sync-log.json`.

If a new meeting pattern was discovered and the user confirmed a new
mapping:
1. Add the new mapping to `_meeting-map.json`
2. Write the updated file

Do NOT add a mapping for meetings the user declined — those were
labeled `one-off`.

## Step 7: Append to Wrap-Up Draft

After processing all documents in the batch, **append** to
`notes/wrap-up-draft.md` under a timestamped section header. **Do not
overwrite prior content** — `wrap-up-draft.md` is a shared staging
area that the companion `wrap-up` skill also writes to, and the user
reviews everything together before applying. Each skill's writes live
under their own header so the user can tell them apart.

If the file doesn't exist, bootstrap it with `# Wrap-Up Draft\n\n`,
then append your block.

Section header format (use current local time):

```markdown
## <YYYY-MM-DD HH:MM> — sync-meeting-notes
```

Under that header, append the sub-sections below. **Omit any
sub-section with no content for this batch.**

```markdown
## <YYYY-MM-DD HH:MM> — sync-meeting-notes

### Meetings Processed
- [Meeting name] ([date]) — [1-sentence summary] — [Drive link]

### Impact Log Entries (for review)

#### [Dimension] > [Sub-dimension]

| Date | What I did | Outcome | Who saw it |
|---|---|---|---|
| [date] | [specific action] | [what changed] | [named witnesses] |

### Key Decisions Updates (for review)

#### [Meeting series]

| Date | Decision | Who decided | Impact |
|---|---|---|---|

### Rolling Context Updates (for review)

- [ ] [Section]: [proposed change] (source: [meeting, date])

### Stakeholder Profile Updates (for review)

#### [Name]
- [Signal with date and context]
```

## Step 8: Report

After writing the draft, report to the user:

- How many were newly processed this batch, broken down by meeting
  series
- How many were already processed (skipped)
- How many were ignored (permanently skipped)
- **How many remain unprocessed** (if the batch was capped)
- Any new mappings created
- Any errors encountered

Example (batch run):

```
Extracted insights from 5 of 22 meeting notes (45 already up to date):
  - Team Standup: 2 notes (Mar 18 – Mar 25)
  - Manager 1:1: 1 note
  - Product Review: 1 note
  - one-off: 1 note

17 older notes remain unprocessed. Run "sync meeting notes" again to get the next batch.

Staged in notes/wrap-up-draft.md. Want me to apply the changes now?
(If Preflight is installed, it will surface these tomorrow morning automatically.)
```

Example (clean run):

```
Extracted insights from 3 new meeting notes (62 already up to date):
  - Team Standup: 1 note
  - Manager 1:1: 1 note
  - Product Review: 1 note

All caught up! Staged in notes/wrap-up-draft.md. Want me to apply the changes now?
(If Preflight is installed, it will surface these tomorrow morning automatically.)
```

Ask the user if they want to apply the staged changes. If they
confirm:

1. **Key Decisions Updates** → append new rows to the relevant
   `notes/meetings/<series>/key-decisions.md`
2. **Rolling Context Updates** → apply proposed changes to
   `context/rolling-context.md`
3. **Stakeholder Profile Updates** → update relevant files in
   `context/stakeholder-profiles/`
4. **Impact Log Entries** → append to the relevant dimension sections
   in `notes/impact-log.md`

If the user declines or wants to edit first, stop.

---

## Incremental Sync & Batching

On subsequent runs, the skill skips documents already in
`_sync-log.json` or `_sync-ignore.json`, making repeat runs fast.
Combined with the 5-document batch cap:

- **Typical run (caught up):** 0-2 new docs → finishes in one run
- **After a gap:** many new docs → processes 5 most recent, reports
  remainder
- **Backfill:** user runs "sync meeting notes" repeatedly to catch up
  in batches

To force a full re-sync, clear `_sync-log.json` back to
`{ "synced": [] }`.

### Why the batch cap exists

Without a cap, 20+ unsynced documents cause the agent to hold too
much data in working memory. The 5-doc cap keeps each run focused
and reliable.

### Known anti-pattern: ID confusion (THE #1 CAUSE OF FAILURES)

**If the skill is failing, this is almost certainly why.** The agent
confuses Google Drive file IDs with file paths or document content.

| Identifier type | What it looks like | What you do with it |
|---|---|---|
| Google Drive `fileId` | `1uTBf2UA0Vx7GZ...` (long alphanumeric) | Pass to MCP tools as `fileId` param. NOTHING ELSE. |
| Section index | `section-0`, `section-1`, etc. | You build these from `totalSections`. Pass to `get_document_section`. |
| Document name | `"Team Standup - 2026/03/18 10:00 EDT - Notes by Gemini"` | Human-readable title. Use to identify which doc you're processing. |

**These three things are completely different. Never substitute one
for another.**

- `fileId` → MCP tools only (never `Read`, never display)
- Document name → working table reference only (never pass to MCP
  tools as fileId)
- Section index → `get_document_section` only (you build these,
  never from API)

---

## Extend this skill

Sync-meeting-notes writes to `notes/wrap-up-draft.md` under a
timestamped `## <YYYY-MM-DD HH:MM> — sync-meeting-notes` header. You
can hook your own post-processing skill into this pipeline:

1. Write a skill that reads the most recent sync-meeting-notes block
   from `notes/wrap-up-draft.md` and extracts additional categories
   the base skill doesn't cover (OKR updates, budget signals,
   role-specific decisions, etc.).
2. Append your skill's output below sync's under its own timestamped
   header (`## <timestamp> — <your-skill>`). Never overwrite prior
   sections.
3. The user reviews everything together when the companion `wrap-up`
   skill's Step 5 asks "apply now?".

**Example use case:** a metrics-mention extractor that pulls any
quantitative claims from meeting notes into a separate review table.
