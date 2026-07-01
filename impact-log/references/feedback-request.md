# `feedback-request` — Collect Feedback for Performance Reviews

Collect feedback about yourself ahead of a performance or development review, and follow up until the deadline. Three flows cover the full feedback lifecycle:

| Flow | Who you ask | Which form | Who uses it |
|------|-------------|------------|-------------|
| `peer` | Peers / collaborators you choose | Peer-feedback form (IC-to-IC or manager-to-manager template) | IC and EM |
| `manager-eval` | Your manager or evaluator | Manager's-evaluation-of-you form | IC and EM |
| `upward` | Your direct reports | Manager-feedback form (reports evaluating you) | EM only |

Each flow independently tracks recipients, sends up to three messages per person per cycle (initial ask, mid-cycle reminder, deadline-day final), detects submissions by reading the form's response spreadsheet, and respects a 24-hour cooldown between contacts.

## When to use

- "Kick off my feedback cycle" / "ask my peers for feedback"
- "Request my manager's evaluation"
- "Send the feedback reminders" / "nag my feedback list"
- "Ask my reports for manager feedback" (EM)
- "Who hasn't submitted feedback yet?"

## Connectors

Written against capabilities, not specific MCP servers:

- **Chat/DM tool** — message recipients (e.g., Slack MCP: search user by email, send DM). Default delivery channel. Falls back to draft-only or email if no chat connector is available.
- **Google Drive / Sheets tool** — copy a template form into the user's Drive at setup; read the form's linked responses spreadsheet to detect submissions.
- **Google Forms** (optional) — if `/google-workspace forms clone` is available, the setup wizard uses it for programmatic form copying. Otherwise, the user copies manually in the Forms UI. **Prerequisites:** (1) `gcloud auth login --enable-gdrive-access` for Workspace scopes, and (2) the Google Forms API must be enabled on the user's GCP quota project (`gcloud services enable forms.googleapis.com --project=<project>`). If either prerequisite is missing, the skill falls back to manual form copying with instructions.

## Configuration: template forms

These are the canonical template forms the setup wizard copies into the user's Drive. The user configures these on first run — no URLs are baked in.

| Template | Config key | Description |
|----------|-----------|-------------|
| Peer feedback — IC-to-IC | `template_peer_ic_url` | Peer-to-peer feedback form for individual contributors |
| Peer feedback — Manager-to-Manager | `template_peer_mgr_url` | Peer-to-peer feedback form for managers |
| Manager's evaluation of you | `template_manager_eval_url` | Form for your manager to evaluate your performance |
| Manager feedback (upward) | `template_upward_url` | Form for your reports to evaluate you as their manager |

Template URLs are stored in the flow's state file after first setup. A shared template folder with example forms is maintained by the Sessions Impact & Performance working group.

## First-run setup (setup wizard)

Run on first invocation or when the user says "set up / reconfigure my feedback cycle." Ask only for what is missing; if a state file already exists for a flow, skip setup for that flow.

1. **Which flow(s)?** Ask whether they want to run `peer`, `manager-eval`, `upward`, or a combination. Each runs independently.

2. **Role (peer flow only).** Ask whether the user is an IC or a manager. This selects the peer template: IC uses `template_peer_ic_url`, manager uses `template_peer_mgr_url`.

3. **Copy the form.** For each flow being set up, copy the chosen template into the user's Drive:
   - If `/google-workspace forms clone` is available, use it programmatically. Name the copy `<Flow> feedback for <user> — <cycle>`.
   - Otherwise, instruct the user to open the template in Google Forms, choose **Make a copy**, and paste the new form's response URL and linked spreadsheet ID.
   - Record `form_url`, `spreadsheet_id`, and `name_column_header` (the exact header of the question that captures the respondent's name).

4. **Recipients.** Ask for the list of people to request feedback from. Each entry needs a name and email. For `upward`, this is the user's direct reports. For `manager-eval`, often a single person.

5. **Cycle, deadline, cadence.**
   - **Cycle label** — free text (e.g., `H1 2026`, `2026 mid-year`)
   - **Deadline** — due date (`YYYY-MM-DD`) and timezone (default `America/New_York`)
   - **Cadence** — the first reminder fires only once `last_contact_at` is more than 24h old; effective gap equals how often the user runs the skill

6. **Delivery channel.** Default: direct messages via chat tool. Alternatives: "draft only" (compose but don't send) or "email."

Write the state file and continue into the workflow.

## State files

One per flow, stored in `feedback-reminders/` within the user's working directory:

- `peer` → `feedback-request-peer-state.json`
- `manager-eval` → `feedback-request-manager-eval-state.json`
- `upward` → `feedback-request-upward-state.json`

### Schema (shared across all flows)

```json
{
  "flow": "peer",
  "role": "ic",
  "cycle": "H1 2026",
  "deadline": "2026-06-15",
  "deadline_tz": "America/New_York",
  "delivery": "dm",
  "form_url": "https://.../viewform",
  "spreadsheet_id": "...",
  "name_column_header": "Your name",
  "last_run_at": null,
  "recipients": [
    {
      "name": "Full Name",
      "email": "person@example.com",
      "chat_user_id": null,
      "initial_ask_sent_at": null,
      "initial_ask_sent_via": null,
      "reminders_sent": 0,
      "last_contact_at": null,
      "submitted_this_cycle": false,
      "submitted_detected_at": null,
      "history": []
    }
  ]
}
```

- `role` — `ic` or `manager`; only meaningful for the `peer` flow (selects template).
- `initial_ask_sent_via` — free-text note for asks made through another channel (e.g., `"mentioned in our 1:1 on 2026-05-05"`). Marks someone as asked without the skill having sent a DM.
- `reminders_sent` — count of follow-up reminders (0, 1, or 2). Does not include the initial ask.
- `last_contact_at` — timestamp of the most recent message; drives the 24h cooldown.
- `history` — append-only list of `{ "sent_at": "<ISO 8601>", "variant": "initial" | "first" | "final" }`.

## Workflow

### Step 1: Pick flow and load state

Determine which flow from the invocation ("peers" → `peer`; "manager evaluation" → `manager-eval`; "upward / reports" → `upward`; ambiguous → ask). Load the flow's state file; if it doesn't exist, run the setup wizard. If `recipients` is empty, stop.

### Step 2: Check cycle window

Compute "today" in `deadline_tz`. If today is after `deadline`, summarize final state and ask whether to start a new cycle. Do not auto-roll-over.

### Step 3: Refresh submission flags

Read the responses spreadsheet with the connected Drive/Sheets tool. Keep only rows inside the cycle window. Match names to recipients (case-insensitive substring, then first-token nickname matching). For ambiguous matches (two recipients share a first name), leave both as not-submitted and surface the ambiguity. Anonymous submissions are noted but cannot be attributed.

Save state after updating `submitted_this_cycle` flags.

### Step 4: Decide sends

For each pending recipient (`submitted_this_cycle == false`):

**Normal day (today < deadline):**
1. No initial ask yet → send `initial`
2. Initial sent, `reminders_sent == 0`, `last_contact_at` > 24h ago → send `first`
3. Otherwise skip

**Deadline day (today == deadline):**
- For each pending recipient with `reminders_sent < 2` → send `final`

### Step 5: Confirm initial asks

If the run includes any `initial` sends, summarize the list of recipients and confirm before proceeding to message composition. This is a lightweight "are these the right people?" check before Step 7 composes and previews the actual messages.

### Step 6: Resolve chat IDs

Look up each recipient's `chat_user_id` by email via the chat tool. Cache the ID. Skip recipients with no match. (Skip entirely for `draft` or `email` delivery.)

### Step 7: Send messages

Before sending, show the user a preview of every message that will be sent in this run — recipient name, message variant (initial/first/final), and the full message text. Ask for confirmation: "Send these N messages?" The user can edit individual messages, skip specific recipients, or cancel the entire run. Only send after explicit approval.

After each send, update the recipient's state (`initial_ask_sent_at`, `reminders_sent`, `last_contact_at`, `history`).

#### Message templates

**`peer` flow:**

| Variant | Message |
|---------|---------|
| `initial` | hey, I'm collecting peer feedback for my upcoming review and was hoping you'd fill out this short form about working with me: {form_url}. it's about 10 minutes, and your perspective genuinely helps me get better as a collaborator. if you can, I'd love it by *{deadline_pretty}* |
| `first` | hey, gentle nudge on the peer feedback form when you get a chance — {form_url}. deadline is *{deadline_pretty}* and it's only ~10 minutes. really appreciate it |
| `final` | hey — today's the deadline for my {cycle} peer feedback and I haven't gotten yours yet: {form_url}. if you can spare ~10 minutes today it'd mean a lot; no worries if today doesn't work, just let me know |

**`manager-eval` flow:**

| Variant | Message |
|---------|---------|
| `initial` | hey, for my {cycle} review I need a manager evaluation and was hoping you'd fill out this form about my work: {form_url}. it should take ~10–15 minutes. if possible I'd appreciate it by *{deadline_pretty}* so it's in ahead of the review |
| `first` | hey, circling back on the manager evaluation form for my {cycle} review when you have a moment — {form_url}. deadline is *{deadline_pretty}*. thank you |
| `final` | hey — today's the deadline for the {cycle} manager evaluation and I don't have it yet: {form_url}. if you can fit it in today it would really help me close out the review; let me know if you need anything from me |

**`upward` flow:**

| Variant | Message |
|---------|---------|
| `initial` | hey, kicking off the {cycle} manager feedback cycle. when you get a chance, would you fill out this form for me by *{deadline_pretty}*? {form_url} — it's about 10 minutes, and the input genuinely helps me get better as a manager |
| `first` | hey, gentle reminder to fill out the manager feedback form for me for {cycle} ({form_url}) by *{deadline_pretty}*. it's only ~10 minutes and it's a real help for me getting better as a manager |
| `final` | hey — today's the deadline for the {cycle} manager feedback form and I haven't gotten yours yet: {form_url}. if you can spare ~10 minutes today it would really help; no worries if today doesn't work, just let me know |

### Step 8: Save state and summarize

Set `last_run_at` and write state. Report:

```
Feedback request — {flow} — {cycle} — {date}

Sent (N):
- Full Name (initial ask)
- Full Name (first reminder)

Skipped — already submitted:
- Full Name (detected ...)

Skipped — cooldown (last contact within 24h):
- Full Name

Skipped — at 2-reminder cap, still pending:
- Full Name — may need a nudge through another channel

Anomalies:
- 1 anonymous submission could not be attributed
```

## Starting a new cycle

1. Set new `cycle` and `deadline`
2. Reset per-cycle fields for all recipients (`initial_ask_sent_at`, `reminders_sent`, `last_contact_at`, `submitted_this_cycle`, `history`)
3. Optionally make a fresh copy of the form for clean responses
4. Re-confirm the recipient list (peer lists change each cycle; manager-eval usually stays; upward roster changes with reporting-line changes)

## Scheduling

Set up a scheduled task whose prompt names the flow (e.g., "run feedback-request for the peer flow"). Daily run gives ~24h reminder spacing; weekly gives ~1 week. The skill self-limits to one initial ask, one mid-cycle reminder, and one deadline-day final per recipient.

## Composition

| Skill | How they connect |
|-------|-----------------|
| [`gather`](gather.md) | `gather` Step 7 (Slack) can surface recognition threads that mention feedback you received; `feedback-request` handles the collection side |
| [`compile`](compile.md) | `compile` references collected feedback when drafting the Looking Back section |
| [`/google-workspace forms clone`](../../../../google-workspace/skills/google-workspace/SKILL.md) | Programmatic form copying during setup wizard |
| [`prep`](prep-interactive-flow.md) | `prep` discovery mode can reference collected feedback as evidence |

## Privacy

- The skill messages only the recipients the user explicitly names — no auto-discovery of peers or reports
- Response detection reads only the user's own form response spreadsheet
- Draft-only mode lets the user review all messages before any are sent
- State files are local and user-controlled; no data leaves the user's machine except via the chat tool when messages are sent
- No tracking of decline rates, response times, or feedback content beyond the binary submitted/not-submitted flag
