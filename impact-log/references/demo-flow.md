---
name: impact-log-demo
description: Guided presenter workflow for demoing the impact-log plugin to a live audience. Use when the user asks to run, rehearse, fix, or walk through an impact-log live demo, especially for a Sessions or studio audience, or says phrases like "run the impact-log demo", "demo impact-log", or "walk me through the impact-log workflow". Provides narration, example output preview, pacing, fallback handling, and prevents mistaken repo-wide searches.
---

# Impact Log Demo

Use this skill to guide a live audience through the impact-log plugin demo. Treat the task as a presentation workflow unless the user explicitly asks to inspect or edit implementation code.

## Operating Rules

- Do not search the current repository for an impact-log entrypoint just because the user says "run the demo". The demo is a scripted plugin walkthrough, not a local service launch.
- Address the live audience, not only the presenter. Keep narration conversational and concrete.
- Before starting, give the audience the five-step overview below.
- Before starting, ask: "Would you like me to show example output for each step?" Default to yes for live demos, ask for dry runs. If the user says yes (or it's a live demo), display the **Example output** code block verbatim from this file before each step so the audience sees what the output typically looks like. Do not skip or summarize the example output when it is enabled.
- After each step: explain what changed, then ask: "Ready for the next step?" Wait for confirmation unless the user asks to run straight through.
- If live execution produces different output than the example, briefly explain why (e.g., different data, different destination choice) — the example is representative, not exact.
- Treat `/plugin` and `/impact-log` lines as Claude Code/plugin slash commands. Do not run them in a normal shell. If the current environment has no slash-command runner, present them as copy-paste commands for the presenter.
- Do not move, delete, or rename `~/.impact-log` without explicit user approval. For a clean first-run demo, suggest a timestamped backup command and wait for approval before running it.
- If auth, VPN, network, or plugin installation blocks the live run, acknowledge it briefly, show the example output for that step, and switch to the fallback walkthrough if needed.

## Two Modes

- **Live demo** ("demo for an audience", "let's do a live demo"): Narrate + show example output + execute live + pause between steps + fallback if blocked
- **Dry run / tutorial** ("dry-run the demo", "rehearse", "walk me through it"): Same narration and example output (serves as a learning walkthrough) + continuous flow without pauses + collect and report issues at the end

## Opening

Say:

```text
We'll walk through five steps:
1. Install - add the Sessions marketplace and the impact-log plugin
2. Init - set up a new log and choose where it lives
3. Backfill - recover evidence from Jira and GHE that predates today
4. Prep - draft Workday-ready self-reflection from logged evidence
5. Status - see what's covered and where gaps remain
```

Then say:

```text
Each step is intentionally small. The point is to show that impact logging can become a lightweight habit instead of a last-minute archaeology project. Before each step, I'll show you what the output typically looks like.
```

## Step 1: Install

Narrate:

```text
First, we add the Sessions marketplace, which is a shared collection of skills and plugins. Then we install impact-log from it. This is one-time setup.
```

**Example output:**

```text
> /plugin marketplace add git@ghe.spotify.net:personalization/sessions-claude-marketplace.git
✓ Marketplace added: sessions-claude-marketplace (23 plugins available)

> /plugin install impact-log@sessions-claude-marketplace
✓ Plugin installed: impact-log v0.10
  Skills: impact-log (capture, prep, status, rescue, feedback-request)
  References: 14 files loaded
```

Present or run in the supported plugin environment:

```text
/plugin marketplace add git@ghe.spotify.net:personalization/sessions-claude-marketplace.git
/plugin install impact-log@sessions-claude-marketplace
```

After:

```text
The marketplace and plugin are installed. From here on, impact-log is available as a local workflow in this agentic tool.
```

Ask: "Ready for the next step?"

## Step 2: Init

Narrate:

```text
Now we initialize the log. The skill will ask where you want your evidence to live — a local file, a GitHub repo, a Google Doc, or a Google Sheet. The important part is that the user controls the destination.
```

**Example output:**

```text
> /impact-log init

Welcome to impact-log! Let's set up your evidence log.

Where would you like your log to live?
  1. Local file (~/.impact-log/impact-log.md)
  2. GitHub repository
  3. Google Doc
  4. Google Spreadsheet

> 1

✓ Log initialized at ~/.impact-log/impact-log.md
  Career level: not set (use --level to configure)
  I&DT cycle: July 2026 (mid-year) — window open June 8 – July 3

You likely have evidence from this quarter already. GHE PRs, Jira
tickets, and Slack messages from the last 90 days can be pulled
into your log now — no manual entry needed.

Would you like to run these now?
  1. /impact-log add --from ghe — your authored and reviewed PRs
  2. /impact-log add --from jira — your assigned and reported tickets
  3. /impact-log rescue — Slack threads approaching retention limits
```

If an existing log prevents the first-run flow, say:

```text
This machine already has an impact log, so init may skip the first-run experience. For a clean demo, I can back it up with a timestamp and restore it afterward.
```

Only after explicit approval, run:

```bash
mv ~/.impact-log ~/.impact-log-backup-$(date +%Y%m%d-%H%M%S)
```

Present or run:

```text
/impact-log init
```

After:

```text
Init is complete. Notice the backfill nudge — the skill detected that this is a new log and offered to pull in existing evidence. That's what we'll do next.
```

Ask: "Ready for the next step?"

## Step 3: Backfill

Narrate:

```text
This is the key moment. The skill can pull evidence from systems where work already happened — Jira tickets, GHE pull requests — instead of asking the user to remember everything manually.
```

**Example output:**

```text
> /impact-log add --from jira

Scanning Jira for tickets assigned to you (last 90 days)...

Found ~20 tickets across 2 projects:
  [PROJECT-A]: ~15 tickets (10 closed, 3 in progress, 2 backlog)
  [PROJECT-B]: ~5 tickets (4 closed, 1 in progress)

Adding completed tickets as evidence entries...

✓ ~14 entries added to your impact log
  Business Impact: 8 entries
  Craft Excellence: 4 entries
  Culture & Organization: 2 entries

Each entry includes: title, outcome summary, Jira link,
dimension mapping, and AI accountability note.
```

The init flow may offer a backfill nudge automatically. If not, present or run one source at a time:

```text
/impact-log add --from jira
/impact-log add --from ghe
```

After:

```text
Notice that each source is explicitly invoked. Nothing silently watches the user — you ask for the source, review the result, and keep control of what lands in the log.
```

Ask: "Ready for the next step?"

## Step 4: Prep

Narrate:

```text
Now for the payoff. Prep takes your logged evidence and drafts Workday-ready self-reflection answers — three questions, 500 characters each, grounded in what you actually did.
```

**Example output:**

```text
> /impact-log prep

Analyzing ~14 logged entries across 3 dimensions...
Applying Performance@Spotify WHAT × HOW framework...
Running bias checks (activity trap, comfort trap, HOW missing)...

━━━ Question 1: What impact did you deliver? ━━━

Shipped [feature] that improved [key metric] by N% in A/B
testing. Led investigation into production monitoring gaps
that resulted in two follow-up improvements. Contributed a
shared tool adopted by teammates across the product area.
[423 / 500 characters]

━━━ Question 2: How did you deliver it? ━━━

One Team: Partnered across teams on a shared infrastructure
dependency and coordinated cross-team incident response.
Human Judgement: Challenged initial root-cause attribution
with independent source code analysis. Make It Happen:
Built a self-serve workflow after feedback from a teammate
in another product area.
[461 / 500 characters]

━━━ Question 3: What will you focus on next? ━━━

Improve error handling in a production service to reduce
false alerts. Update internal tooling templates to align
with the latest framework changes. Continue growing
adoption of shared resources across the organization.
[389 / 500 characters]

⚠ Bias check: Question 1 lists 3 outcomes — consider
  whether the feature impact is the strongest lead, or
  if the investigation had broader organizational impact.
```

Present or run:

```text
/impact-log prep
```

After:

```text
The draft starts from real evidence, so the user edits judgment and wording instead of reconstructing the year from scratch. Notice the bias check at the end — the skill applies the same quality checks as the official HR coaching skills.
```

Ask: "Ready for the final step?"

## Step 5: Status

Narrate:

```text
Finally, status shows your coverage dashboard — which dimensions have evidence, which are thin, and where to focus next before the review window closes.
```

**Example output:**

```text
> /impact-log status

Impact Log Status — [Current Cycle]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Entries: ~14 total (~12 from Jira, ~2 manual)
Period: [Last 90 days]

Dimension Coverage:
  Business Impact        ████████░░  8 entries
  Craft Excellence       ████░░░░░░  4 entries
  Culture & Organization ██░░░░░░░░  2 entries

Gaps:
  ⚠ Culture & Organization is thin — consider logging
    mentoring, code reviews, or cross-team collaboration
  ⚠ No Slack evidence rescued — run `rescue` to catch
    recognition threads before 90-day retention

I&DT window: [current window status]
  Run `prep` to draft your Workday self-reflection.
  Run `prep --calibrate` to self-check with the manager lens.
```

Present or run:

```text
/impact-log status
```

After:

```text
That's the workflow: init once, add as work happens, backfill when needed, prep when the review window opens, and use status to spot gaps early.
```

## Fallback Walkthrough

Use this when the live demo is blocked by auth, VPN, network, missing plugin commands, or an audience timing issue. The example output above can still be shown even without live execution — walk through the examples as "here's what this typically looks like" while pointing the audience to the walkthrough for hands-on practice.

Say:

```text
Let me switch to the interactive walkthrough. It covers the same flow with copy-pasteable commands, so you can try it at your own pace.
```

If the Sessions marketplace repo is checked out locally, point to:

```text
plugins/setup-onboarding/skills/setup-onboarding/references/impact-and-development-talk-walkthrough/index.html
```

If the repo is not local, point to the internal GHE page for the same walkthrough:

```text
https://ghe.spotify.net/personalization/sessions-claude-marketplace/blob/master/plugins/setup-onboarding/skills/setup-onboarding/references/impact-and-development-talk-walkthrough/index.html
```
