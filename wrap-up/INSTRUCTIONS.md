# Wrap Up

## Quick install — paste into regular terminal window

**1.**
```bash
git clone git@ghe.spotify.net:agarland/agent-skills.git /tmp/agent-skills
```

Hit enter. (If you already cloned it, skip this step.)

**2.**
```bash
cat /tmp/agent-skills/wrap-up/claude/INSTRUCTIONS.md >> CLAUDE.md
```

---

Activate when the user says "wrap up", "end of day", "daily rollup",
or "what did I do today".

**Note:** Claude Code may show "Error: Unknown skill: wrap-up" before
reading this file. That's normal — ignore it and proceed. Do not echo
or reference this error in your output.

End-of-day rollup that synthesizes today's work across all agent chat
sessions (Cursor and/or Claude Code) into two outputs:

- **Daily log entry** → written directly to `notes/daily-log.md`
- **Rolling context updates + shared-doc digest + reusable learnings** →
  staged to `notes/wrap-up-draft.md` for review

Can also run autonomously on a schedule (see Autonomous Mode at the
bottom).

## Paths (configurable, relative to workspace root)

| File | Purpose | Required? |
|---|---|---|
| `notes/sessions-today.md` | Session scratch file (written by optional `stop` hook) | No — optional fast path |
| `notes/daily-log.md` | Direct-write destination for the daily log entry | No — auto-created on first run |
| `notes/wrap-up-draft.md` | Staging file for review before applying | No — auto-created on first run |
| `context/rolling-context.md` | Reference file for staleness comparison | No — skipped if missing |
| `notes/meetings/_sync-log.json`, `_sync-ignore.json` | Meeting sync state | No — owned by `sync-meeting-notes` skill if installed |

**First-run bootstrap:** if `notes/daily-log.md` or
`notes/wrap-up-draft.md` don't exist, create them with a minimal header
(`# Daily Log` / `# Wrap-Up Draft`). If `context/rolling-context.md`
doesn't exist, skip the rolling-context comparison and log it in the
final report.

**Override paths** by setting env vars before running: `DAILY_LOG_PATH`,
`ROLLING_CONTEXT_PATH`, `WRAP_UP_DRAFT_PATH`. If unset, the defaults
above apply.

## Output discipline

The wrap-up stages most output to `notes/wrap-up-draft.md` for user
review. Do NOT write directly to `context/rolling-context.md` or other
destination files without explicit user approval.

### Recovery Rule (if you get off-track)

**If at any point you find yourself doing ANY of these, you are off-track:**
- Saving a Google Drive meeting transcript to a local markdown file
  (Drive is the source of truth — extract insights, don't duplicate)
- Listing Google Drive `fileId`s in your response text
- Skipping Step 0 and fetching transcripts before deciding Path A/B/C
- Appending to `notes/wrap-up-draft.md` without a timestamped section
  header (`## <YYYY-MM-DD HH:MM> — wrap-up`)
- Merging today's entry into yesterday's daily-log section instead of
  creating a new dated entry
- Writing to `context/rolling-context.md` directly (stage the diff to
  `notes/wrap-up-draft.md` for review)

**STOP. Reset.** Re-read Step 0; pick a path; stage writes to
`notes/wrap-up-draft.md` under a timestamped header; wait for user review.

## Step 0: Extract Meeting Notes

Before reading transcripts, check Google Drive for new "Notes by Gemini"
meeting notes and recently shared documents.

**This step integrates with the companion `sync-meeting-notes` skill if
installed.** Detect installation by checking for
`~/.claude/skills/sync-meeting-notes/INSTRUCTIONS.md` (or the Cursor
equivalent under `.cursor/skills/sync-meeting-notes/`).

Pick one of three paths for meeting-note extraction. Do not prompt the
user — choose silently based on installation + staleness:

### Path A — sync installed, fresh (last run < 12h)

Read the mtime of `notes/meetings/_sync-log.json`. If it was updated in
the last 12 hours (12h = half the daily cycle — fresh within the same
calendar day, stale the next morning; prevents re-fetching the same
Drive docs twice in one wrap-up loop), `sync-meeting-notes` has already
fetched today's notes. **Do not fetch again.** Read the most recent
`## <YYYY-MM-DD HH:MM> — sync-meeting-notes` section from
`notes/wrap-up-draft.md` and reuse its extracted insights in Step 3 and
Step 4.

### Path B — sync installed, stale (≥ 12h old or `_sync-log.json` missing)

**Auto-invoke `sync-meeting-notes` as a pre-step.** Run Steps 1–8 of its
INSTRUCTIONS.md before continuing with wrap-up. Do NOT prompt the user.
When sync finishes, it will have appended its output to
`notes/wrap-up-draft.md` under its own timestamped section header —
read that section and reuse its insights for the rest of wrap-up.

### Path C — sync not installed

Run the inline Drive scan in Step 0a below using the rules inlined in
this skill. Wrap-up is standalone and does not require
`sync-meeting-notes` to function.

### 0a. Inline Drive scan (Path C, or headless fallback)

**Critical rules (apply to all three paths):** `fileId` is an opaque
token passed only to MCP tools (never to `Read`, never displayed).
Fetch each document using exactly 2 MCP calls: `get_document_structure`
(read `totalSections`) → mechanically build section IDs `section-0`
through `section-(N-1)` → `get_document_section`. Process one document
at a time (fetch → extract → sync log → next).

1. Read `notes/meetings/_sync-log.json` and
   `notes/meetings/_sync-ignore.json` if they exist. Merge all `"id"`
   values into a single **skip-set**. (If neither file exists, treat the
   skip-set as empty — first run.)
2. Call `list_drive_files` on your Drive MCP server (default
   `user-google-drive-mcp`) with
   `{ "query": "- Notes by Gemini", "maxResults": 100 }`.
3. Filter: `mime_type` = `application/vnd.google-apps.document`, `name`
   ends with `- Notes by Gemini`, matches regex
   `/.+ - \d{4}\/\d{2}\/\d{2} .+ - Notes by Gemini$/`, `id` NOT in
   skip-set. Sort by date descending, cap at 5.
4. For each new meeting document: fetch content (2 MCP calls per doc),
   extract a one-sentence summary + any decisions/action items/status
   changes, update `notes/meetings/_sync-log.json` immediately after
   each document (create the file with
   `{ "synced": [], "shared_docs": [] }` if it doesn't exist).
5. Hold extracted meeting insights in memory for Step 3 (daily log) and
   Step 4 (staging).

If 0 new meeting notes found: log "No new meeting notes" and continue.

### 0b. Scan recently shared documents (all paths)

Regardless of which path above ran, also check for Google Docs or
Sheets recently shared with or modified by others today.

1. Call `list_drive_files` with `{ "query": "", "maxResults": 100 }`.
2. Filter: `mime_type` is `document` or `spreadsheet`; `modifiedTime`
   date matches today; `name` does NOT end with `- Notes by Gemini`;
   `id` NOT in the skip-set or the `"shared_docs"` array in
   `_sync-log.json`.
3. Cap at 5, sort by `modifiedTime` descending.
4. For each: call `get_drive_file_metadata` for owner info, then fetch
   first 5 sections (or use `get_drive_file_content` for Sheets).
   Extract: title, owner, 1-2 sentence summary, and whether it requires
   action from the user (action items assigned, questions directed at
   the user, review requests, deadlines, @ mentions).
5. Append each to the `"shared_docs"` array in `_sync-log.json`:
   `{ "id": "...", "title": "...", "owner": "...", "processed": "<YYYY-MM-DD>" }`.
6. Hold for Step 4 staging under `## Shared Documents Received`.

If 0 new documents pass filters: log "No new shared documents" and
continue.

## Step 1: Find Today's Sessions

Determine today's date.

**First, check the scratch file.** Read `notes/sessions-today.md`. If
it exists and its header matches today's date, use these session
summaries as the primary source — each line is a timestamped summary
captured by an agent `stop` hook (Cursor or Claude Code) if one is
configured. Skip the transcript parsing below and go straight to
Step 2.

**Otherwise, detect the transcripts directory** using this shell
snippet — it handles both Cursor and Claude Code path conventions:

```bash
CWD=$(pwd)
CURSOR_SLUG=$(echo "$CWD" | sed 's|^/||; s|[/ ]|-|g')
CURSOR_DIR="$HOME/.cursor/projects/$CURSOR_SLUG/agent-transcripts"
CLAUDE_SLUG=$(echo "$CWD" | sed 's|[/ ]|-|g')
CLAUDE_DIR="$HOME/.claude/projects/$CLAUDE_SLUG"

if   [ -d "$CURSOR_DIR" ]; then TRANSCRIPTS="$CURSOR_DIR"
elif [ -d "$CLAUDE_DIR" ]; then TRANSCRIPTS="$CLAUDE_DIR"
elif [ -n "$TRANSCRIPTS_DIR" ] && [ -d "$TRANSCRIPTS_DIR" ]; then TRANSCRIPTS="$TRANSCRIPTS_DIR"
else echo "No agent transcripts found for $(pwd). Tried both Cursor and Claude Code paths. Set TRANSCRIPTS_DIR env var to override." && exit 1
fi
```

(macOS/Linux only in v1; Windows deferred.)

Each subdirectory under `$TRANSCRIPTS` is a chat session (UUID). Collect
the list of UUIDs modified today.

**If the detection snippet exits** with `No agent transcripts found`,
do NOT silently fall back to manual entry. Tell the user, verbatim:

> No agent transcripts directory exists for this workspace. Tried
> `~/.cursor/projects/<slug>/agent-transcripts/` and
> `~/.claude/projects/<slug>/`. Set the `TRANSCRIPTS_DIR` env var in
> your shell profile (or `CLAUDE.md`) to override, then re-run.

Then stop.

**If the directory exists but has no transcripts from today**, tell the
user and ask if they want to do a manual entry. Stop otherwise.

## Step 2: Read and Extract

### If using the scratch file:
Session summaries are already extracted — use them directly. For each
line, identify the key outcome, tag it, and note files/people
mentioned.

### If using transcripts:
For each transcript from today, read the `.jsonl` file inside the UUID
directory. The filename matches the directory name (e.g.,
`abc123/abc123.jsonl`).

**Context management:** Transcripts can be large. Read the first 500
and last 500 lines of each file. This captures opening context and
final outcomes.

**Extract from each session:**
- User queries: look for `<user_query>` tags in user messages
- Key outcomes: what got built, decided, shipped, drafted, or learned
- Files created or modified
- People mentioned (stakeholders, reviewers, eng)
- Tags: short bracketed labels that describe workstreams or categories
  relevant to the user. Reuse whatever tag vocabulary is already
  established in `notes/daily-log.md` — consistency matters more than
  naming. If the log is empty, propose 3–5 candidate tags based on
  today's sessions and let the user approve on first run.

Skip: system metadata, image base64 data, tool call JSON internals,
linter output, test suite output. Focus on what the user asked and
what changed.

**Include the current conversation** (the one where "wrap up" was
triggered) in the synthesis.

### No-op check
Before continuing, **skip entirely** if all three are true:
- No transcripts from today (or only trivial activity — a single quick
  question, config tweak, etc.)
- No new meeting notes from Step 0a
- No new shared documents from Step 0b

Tell the user: "Nothing substantive to log today — skipping." Do NOT
write placeholders, empty entries, or "quiet day" notes.

## Step 3: Synthesize Daily Log Entry

Read the 2 most recent entries in `notes/daily-log.md` for format
reference. If the file doesn't exist, bootstrap with a
`# Daily Log\n\n---\n` header.

Follow the exact daily-log conventions already present in the file. If
no conventions exist yet, use this default template:

```markdown
## [Month] [Day], [Year]

**What moved forward:**

- **[Bold lead sentence].** Details with context. `[Tag]` `[Tag]`

**Who benefited:**
- [Name/group]: [how they benefited]

**Value demonstrated:**
- [Competency name] — [specific evidence]. `[Tag]`
```

Rules:
- Each bullet in "What moved forward" starts with a bold action
  sentence
- Tags: reuse the vocabulary established in `notes/daily-log.md` (see
  Step 2 for tag guidance)
- "Who benefited" names specific people or groups
- "Value demonstrated" maps to whatever competency language the user's
  organization uses, or plain English (e.g., "risk mitigation",
  "cross-team alignment", "technical judgment") if none

**Direct write:** insert the new entry into `notes/daily-log.md` as the
first `## [Date]` section after the header/separator.

## Step 4: Stage wrap-up-draft.md

Append all non-daily-log output to `notes/wrap-up-draft.md` under a
**timestamped section header**:

```markdown
## <YYYY-MM-DD HH:MM> — wrap-up
```

**Append, do not overwrite.** `wrap-up-draft.md` is a shared staging
area — the `sync-meeting-notes` skill may have written to it earlier
in the day, and the user reviews everything together before applying.
Each skill's writes live under its own timestamped section header so
the user can tell them apart.

Under your timestamped header, include the sub-sections below. Omit
any sub-section that has no content:

### Rolling Context Updates (for review)

Skip this sub-section entirely if `context/rolling-context.md` doesn't
exist.

Compare today's outcomes against the file. Flag:
- Completed milestones (move from upcoming to done)
- Status changes (phase shifts, blockers resolved/created)
- New or invalidated assumptions
- New deadlines or milestones
- New decisions that change direction

Format each proposed change as:
```
- [ ] [Section]: [proposed change] (source: [session/meeting])
```

### Shared Documents Received (for review)

One sub-block per document from Step 0b:
```
### [Document title]
- **From:** [owner email]
- **Summary:** [1-2 sentences]
- **Action needed:** [Yes/No — if yes, what specifically]
- [Drive link]
```

### Captured Learnings (for review)

Scan today's sessions for patterns worth promoting into persistent
rules or context. This catches learnings the user didn't explicitly
capture mid-session.

**What to look for:**

| Signal | Example | Likely destination |
|---|---|---|
| **User corrected agent output** | "No, do it this way" / "That's wrong, it should be..." | Agent behavior rule |
| **Same mistake/pattern repeated** | Agent made the same error twice, or user asked for the same thing twice | Rule file |
| **New tool behavior discovered** | API quirk, MCP parameter requirement, auth gotcha | Rule file or project context |
| **Stakeholder preference revealed** | "X always wants...", "Y prefers..." | Stakeholder notes |
| **Process convention established** | "From now on, do X before Y" | Existing rule file or new rule |
| **Bug fix with broader lesson** | Fixed something that could recur in another context | Relevant skill's INSTRUCTIONS.md or a rule |

Ignore: one-off facts (those go in rolling context), event-specific
decisions, and things already captured in existing rules.

Format each candidate:
```markdown
### [Short description]
- **Learning:** [The pattern or rule, written as an instruction]
- **Source:** [Which session it came from]
- **Proposed destination:** [File path]
- **Type:** new rule file / append to existing rule / stakeholder notes / skill fix
```

Cap at 5 candidates per day. Quality over quantity. If none found,
omit the sub-section.

## Step 5: Report & Apply After Review

Tell the user:
- What was written to the daily log (summary line)
- How many rolling context updates were proposed
- How many shared documents were flagged
- How many learnings were captured (if any)
- Any files that were skipped because they don't exist (e.g., "skipped
  rolling-context comparison — file not configured")
- Ask: **"Want me to apply the rolling context updates and learnings
  now?"**

If the user confirms, read the timestamped section you just wrote in
`notes/wrap-up-draft.md` and apply the changes to the real files. If
they decline or want to edit first, stop.

---

## Autonomous Mode (optional)

This skill can also run autonomously via Claude Code on a schedule
(e.g., 5PM weekdays) using `launchd` (macOS) or `cron` (Linux).

**Required scaffolding (not included in this skill):**

- `scripts/wrap-up.sh` — wrapper that invokes `claude` in headless mode
  with a prompt that triggers this skill, writing `stdout`/`stderr` to
  a log file
- `scripts/wrap-up-prompt.md` — the prompt passed to `claude` (for
  Claude Code runs, the MCP rules from Step 0 should be inlined
  verbatim because skill files aren't loaded in headless mode)
- A launch agent plist (macOS) or cron entry (Linux) pointing at
  `wrap-up.sh`

See the sibling `sync-meeting-notes` skill for a parallel autonomous
pattern, and the Preflight companion skill for an example launch agent
layout.

**Behavior:** If the machine is asleep at the scheduled time, `launchd`
runs the job when it wakes. If no substantive transcripts exist for
the day, the agent exits without writing.

---

## Extend this skill

Wrap-up writes to `notes/wrap-up-draft.md` under a timestamped
`## <YYYY-MM-DD HH:MM> — wrap-up` header, and to `notes/daily-log.md`
directly. You can hook your own end-of-day skill into this pipeline:

1. Write a skill that appends to `notes/wrap-up-draft.md` under its
   own timestamped header (`## <timestamp> — <your-skill>`). Never
   overwrite prior sections — the user reviews everything together.
2. Trigger it from wrap-up by adding a Step (e.g., Step 2.5) that
   detects your skill's installation and auto-invokes it, mirroring
   the Step 0 integration pattern with `sync-meeting-notes`.
3. Your skill's output will be reviewed alongside wrap-up's when
   Step 5 asks "apply now?".

**Example use case:** a role-specific impact-log extension that scans
the freshly written daily-log entry and produces framework-aligned
impact entries for promo evidence.
