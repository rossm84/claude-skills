---
name: impact-log
description: "Personal log of work examples and outcomes throughout an impact cycle. Captures structured evidence (Pillar / Sub-area / Outcome / AI accountability) aligned with Spotify's Engineering Expectations and the Performance@Spotify framework (WHAT x HOW). Composes with /team-update quarterly (synthesis), /groove-sync (Groove DODs / Epics), /strategy-scope-doc (planning context), and the official impact-dev-talk-employee / impact-dev-talk-manager claude.ai Skills (Workday self-reflection prep and manager-lens calibration). Use when capturing a win or shipping moment, bulk-importing from GHE / Jira / quarterly synthesis, or preparing a Workday-ready self-reflection for an Impact & Development Talk."
metadata:
  author: malcolmh, melissamcguirl (design feedback), smercier (cadence workflows, synthesis templates, JIRA fallback), ikaplun (feedback-request workflow)
  version: "0.10"
  compatibility: "Optional: groove-mcp (for /groove-sync composition), google-drive-mcp (for Google Doc persistence), atlassian-mcp (for Jira evidence rescue), slack-search (for ephemeral Slack evidence rescue)."
  status: experimental
  access:
    type: read-write
    auth: [mcp-server]
  lifecycle: experimental
  discoverable: true
  domain: planning
  tags:
    - scope:domain
    - audience:ic
    - audience:em
    - topic:impact-development-talk
    - topic:evidence-collection
    - topic:self-reflection
    - topic:experimental
  prior_art:
    - "Spotify Engineering Expectations in an AI Era (XTL framework document, https://docs.google.com/document/d/12o2AVnHKmALOqMPaFIZmO2LuNSwatbYBJ8lrKfoZ5xI/) — framework source for the v0.1 template"
    - "Career Steps For Individual Contributors Self-Assessment template by Mfoniso Inoyo, Sarah Mercier, and Malcolm Howard — a review-prep workbook spanning peer feedback aggregation, multi-category dimension scoring, and career-step planning. The structured-evidence capture model from this template informed this skill; the workbook's other capabilities are not implemented here."
    - "/log-impact by Mike Shtryhel at https://ghe.spotify.net/mykhailos/claude-code-setup/blob/master/skills/log-impact/SKILL.md — append-only personal impact log keyed on the same three pillars and sub-principles as the v0.1 template. Direct prior art for the `add` subcommand's data shape."
    - "/dev-talk-prep at https://ghe.spotify.net/shared/sp-claude-code/blob/master/plugins/dev-talk-prep/skills/dev-talk-prep/SKILL.md (Spotify shared Claude Code marketplace) — gathers GitHub / Jira / Google Drive contributions, asks reflective questions, and synthesizes a dev-talk document; supports optional peer feedback intake."
    - "/engineer-impact-mirror (alias /highlight-reel) by the PM-OS team at https://ghe.spotify.net/pm-os/plugins/blob/master/plugins/rhythm/skills/engineer-impact-mirror/SKILL.md — surfaces individual engineer impact mapped to the Performance@Spotify framework (Direct / Enabling / Growing), with engineer-self and manager-about-report modes."
    - "/assess-impact by the Client Platform Localhosts team at https://ghe.spotify.net/client-platform/localhosts-ai-plugins/blob/master/impact-assessment-plugin/skills/assess-impact/SKILL.md — generates a self-assessment scored against the same Engineering Expectations rubric used by this skill (XTL doc 12o2AVnHKmALOqMPaFIZmO2LuNSwatbYBJ8lrKfoZ5xI), pulling from GHE / Slack / Jira and uploading to Google Drive."
    - "localhosts-work-log-plugin (/make-weekly-summary, /make-monthly-management-summary) by the Client Platform Localhosts team at https://ghe.spotify.net/client-platform/localhosts-ai-plugins/blob/master/localhosts-work-log-plugin/ — work-log folder → weekly + monthly digest plugin combining a team work-log directory with Slack / Jira / Drive sources."
    - "/weekly-summary skills across multiple Spotify teams (Samba, Buzz, Parable, Fandango, Ads, and others) — established pattern of per-team weekly digest skills that synthesize Slack / Jira / Drive activity into a weekly readout."
    - "impact-dev-talk-employee claude.ai Skill (official Performance@Spotify tool, accessed 2026-05-28) — coaching-based self-reflection prep for bandmates, targeting the 3 Workday questions with 500-char limits. Applies the WHAT x HOW framework and quality checks (outcomes vs activities, unique strength, expectations grounding). The `prep` subcommand sources evidence from impact-log entries and maps to the same Workday format."
    - "impact-dev-talk-manager claude.ai Skill (official Performance@Spotify tool, accessed 2026-05-28) — manager prep and post-conversation documentation for I&DTs. Provides the self-reflection analysis framework (alignment/divergence, bright spots vs outliers, bias checks) and Workday documentation format. The `prep --calibrate` flag applies this analysis lens to the IC's own draft."
    - "Performance@Spotify playbook (https://docs.google.com/presentation/d/1i0p_sQRPPq1SrHqXrs0Wfs3BAbH2tK8K8GyQ7c5fKB4/) — authoritative company-wide framework defining impact dimensions, WHAT x HOW model, Values in Action, Impact Scale, and Impact & Development Talk structure."
    - "Level-specific I&DT prep templates published by Personalization engineering leadership (accessed 2026-06-08) — Eng I (https://docs.google.com/document/d/1Mo1liBAXeyeS-5eo-olnwH1lV4pjY1JRDj4ZN39iQkE/), Eng II (https://docs.google.com/document/d/1Du-GJ-uW468bHZjn3Wk7zL_UhefSkfpc_AQgLl4iqxA/), Senior Eng (https://docs.google.com/document/d/1X-Gboti_aceCoBOrdXt3qs502NpyFgQlPu_KKYlz8c8/), Staff Eng (https://docs.google.com/document/d/11HTPFEOWmN7kZEiN_Xbt_nz3D4euJnY84vUu5VxmU9U/), EM (https://docs.google.com/document/d/1SMAdq4E5xCIyPNQbNXQEhlffjTLq7SlogpyRIqq6TLY/). Career-level-tailored impact dimensions, reflection questions, and Expectations Sync agendas. Optional — the `prep --level` flag selects one, or users can provide their own custom template."
    - "Workday & Claude companion guide (https://docs.google.com/presentation/d/1j1_54HSyzX-bX8oCNSeMLmVr8GgdEVfcqdDHXrbsXBU/) — step-by-step Workday walkthrough and Claude skill usage instructions for the I&DT cycle."
    - "Impact Info Session — PZN (https://docs.google.com/presentation/d/1ZLCUp3iX_wxjtGWE6-57wliKzxq0DghuUdaNHoMOVkg/, June 2026) — Personalization-specific context for the June 2026 I&DT cycle. Covers what impact means, the Impact Session structure, July vs December cycle differences, and level-specific templates."
    - "contribution-tracker by Sarah Mercier at https://ghe.spotify.net/smercier/cursor-claude-config — cadence-driven contribution accumulation (weekly gather → monthly synthesize → biannual compile) with 8 MCP sources, DELIVERY vs INFLUENCE classification, business context enrichment via Groove/Oliver/Lineage/GDrive, per-level narrative framing, JIRA stale index 4-tier fallback, and pair/mob ticket detection. The cadence model, level-aware source weighting, and business context enrichment patterns directly influenced this skill's design."
    - "dev-talk-report by Sarah Mercier at https://ghe.spotify.net/smercier/cursor-claude-config — biannual Looking Back / Right Now / Looking Ahead synthesis for I&DT conversation prep, with private vs exported content separation (conversation prep material stays local; manager-facing sections export to Google Docs). Directly influenced the planned `compile` subcommand."
    - "Performance and Impact in Samba by Melissa Yalla (https://docs.google.com/document/d/1hBdr0Wtlr4T5hUF0Z_fx6vbMKLLaJxJ8y5WiTJyrt3U/, May 2026) — one of the earliest squad-level impact guides in Sessions, refined with AI assistance. Defines what impact means in the squad's context, how different contributions are valued, and what each Impact Scale level looks like for the team. Became a reference example and directly inspired the Sessions Team Impact Template (https://docs.google.com/document/d/1SxFu8th9GKe-FRTeZaz5wg_sD14q1Cr-Okv79nergus/) and the squad rubric discovery feature in this skill. Part of a broader wave of squad-level impact guides across Spotify (April–May 2026) responding to the Performance@Spotify playbook's call for managers to clarify impact in their team context."
    - "feedback-reminders and manager-feedback-reminders by Ilya Kaplun (June 2026) — two Claude Code skills for collecting peer feedback and upward manager feedback via Google Forms, with setup wizard (form copy, recipient list), 3-stage reminder cadence (initial ask, mid-cycle, deadline-day), response detection via spreadsheet, and 24h cooldown. Connector-agnostic design (chat tool + Drive/Sheets). Directly consolidated into the `feedback-request` subcommand."
    - "write-feedback skill (Premium Desirability team, across 5+ repos at premium-desirability-pi/) — transforms rough feedback notes into polished peer feedback prose with a structured output format (summary, self-identified growth areas, strengths with examples, areas for improvement). Direct precedent for the `feedback-request draft` coaching flow. Key difference: write-feedback takes existing notes as input and polishes them; draft starts from scratch with reflective prompts."
---

# Impact Log (Experimental)

> ⚠ **This skill is an experimental work-in-progress** (`lifecycle: experimental`, `version: 0.10.1`). Subcommand details and template structure may change before a stable release.

## Cross-model compatibility

This skill is packaged as a Claude Code plugin, but the workflow content is plain Markdown. The top-level frontmatter intentionally stays limited to portable keys (`name`, `description`, `metadata`) so stricter non-Claude skill loaders such as Codex can parse it. Capability notes that older marketplace skills put in a top-level `compatibility:` field live under `metadata.compatibility` here.

Slash-command examples such as `/impact-log add --from jira` are Claude Code invocation syntax. In non-Claude tools, treat them as workflow intent labels: load this `SKILL.md`, follow the matching subcommand row, and read the linked reference file when one exists. Do not run slash-command lines in a normal shell unless your client explicitly supports them.

Most evidence-gathering paths depend on capabilities rather than Claude itself: GHE/Jira/Drive/Slack MCP access, local CLIs, or user-provided files. The scheduling helpers are the main Claude-specific exception today because they generate `claude -p "/impact-log ..."` entries; see [`references/schedule.md`](references/schedule.md) before using scheduled runs outside Claude Code.

A personal log of work examples and outcomes for an individual contributor (IC) or engineering manager (EM) throughout an impact cycle. Capture evidence as it happens — not at Impact & Development Talk (I&DT) prep time — so self-reflection becomes synthesis rather than reconstruction.

**Four-step flow at a glance:**

1. **Init once** — `/impact-log init` to scaffold the log and choose where it lives.
2. **Capture as you go** — `/impact-log add` for each win in the moment, or `add --from quarterly` for bulk import from a `/team-update quarterly` synthesis.
3. **Persist when ready** — `/impact-log persist` to push the log to your chosen destination.
4. **Prep for your I&DT** — `/impact-log prep` to draft Workday-ready self-reflection answers from your logged evidence.

Use `/impact-log status` any time to see what's logged and what's missing. Use `/impact-log overview` to re-read this summary.

```
┌─────────────────────────────────────────────────────────┐
│  Setup       init → choose destination                  │
├─────────────────────────────────────────────────────────┤
│  Capture     add (in-the-moment)                        │
│              add --from quarterly / ghe / jira (pull)   │
│              add --from groove-sync                     │
│              rescue (ephemeral evidence)                │
├─────────────────────────────────────────────────────────┤
│  Review      list, status, update                       │
├─────────────────────────────────────────────────────────┤
│  Persist     persist --to {github, gdoc, gsheet, local} │
├─────────────────────────────────────────────────────────┤
│  I&DT prep   prep (Workday-ready self-reflection)       │
│              prep --calibrate (manager-lens self-check)  │
├─────────────────────────────────────────────────────────┤
│  Recurring   schedule (cron / launchd)                  │
└─────────────────────────────────────────────────────────┘
```

## First-run onboarding (REQUIRED on init or first add)

**After `init` completes or after the first `add` to an empty log, you MUST present the automation summary below.** This is the user's one chance to understand the full scope of what the skill can do — do not skip it, bury it in a footnote, or defer it to a follow-up question. Present it inline, immediately after the init/add confirmation.

### What to present

> **Be your best advocate.** Use evidence and AI to market yourself. This skill incorporates the official HR Claude Skills' framework content — the Performance@Spotify WHAT x HOW model, Workday questions, quality checks, and manager-lens bias checks are captured in [`idt-framework-employee.md`](references/idt-framework-employee.md) and [`idt-framework-manager.md`](references/idt-framework-manager.md) — and extends it with evidence-backed prep from your logged entries and connected tools (GHE, Jira, Groove, Oliver, Slack). You can use either or both: the [HR skill](https://docs.google.com/presentation/d/1j1_54HSyzX-bX8oCNSeMLmVr8GgdEVfcqdDHXrbsXBU/) coaches self-reflection from scratch; this skill synthesizes from evidence you've already captured.
>
> **You don't have to capture entries one at a time.** The impact log can pull from 6 sources across 4 systems, scan for expiring evidence, and run on a recurring schedule:
>
> | Source | Command | What it pulls | Best for |
> |--------|---------|---------------|----------|
> | **GHE** | `add --from ghe` | Your PRs (authored, reviewed, commented) for the configured period | ICs, Senior+ |
> | **Jira** | `add --from jira` | Your tickets (assigned, reported, commented) + epics/initiatives you own for the configured period | All roles |
> | **Google Drive** | `add --from drive` (planned) | 1:1 notes, team retros, meeting notes, hiring docs from the configured period. Requires `google-drive-mcp`. Reference doc (`pull-drive.md`) not yet written. | EMs, Senior EMs |
> | **Groove** | `add --from groove-sync` | Goal / Strategy / Metrics from DODs you own | All roles |
> | **Quarterly synthesis** | `add --from quarterly` | Highlights from a `/team-update quarterly` run (Jira + Slack + Drive combined) | All roles |
> | **Ephemeral evidence** | `rescue` | Slack (90d) incl. recognition of team members, Soundcheck (30d), Content-SIM (~90d), DevEx (~13w) — items approaching retention limits | All roles |
> | **All of the above** | `rescue` + `add --from ghe` + `add --from jira` | Run in sequence for a comprehensive sweep | All roles |
>
> **Recurring automation:** `schedule install` registers a weekly local cron (Linux) or launchd (macOS) job to run `rescue` automatically, catching expiring evidence without manual intervention. Preview with `schedule dry-run` first.
>
> Each path requires explicit invocation — nothing runs automatically without your consent.

After presenting this, ask: "Would you like to run any of these now, or continue with manual entries?"

### I&DT walkthrough tip (first run, seasonal)

During I&DT season (May–July, December–January), after the automation summary and before the backfill nudge, mention the walkthrough page:

> **New to Performance@Spotify or the impact-log workflow?** A self-guided walkthrough is available locally.

Offer to open the walkthrough in the user's default browser. Check if the file exists locally first; if not, point to the public URL.

**If the marketplace is installed locally:**

- **macOS:** `open plugins/setup-onboarding/skills/setup-onboarding/references/impact-and-development-talk-walkthrough/index.html`
- **Linux:** `xdg-open plugins/setup-onboarding/skills/setup-onboarding/references/impact-and-development-talk-walkthrough/index.html`
- **Windows:** `start plugins/setup-onboarding/skills/setup-onboarding/references/impact-and-development-talk-walkthrough/index.html`

**If not installed locally** (e.g., user installed only the impact-log plugin):

> You can view the walkthrough on GHE: https://ghe.spotify.net/personalization/sessions-claude-marketplace/blob/master/plugins/setup-onboarding/skills/setup-onboarding/references/impact-and-development-talk-walkthrough/index.html
>
> For the full interactive experience (scroll animations), download the file and open it locally, or install the marketplace with `/plugin marketplace add`.

Present once on first run during I&DT season. Not repeated, not tracked ([ADR-009](../../../../docs/adr/009-contextual-tip-pattern.md)).

### Backfill nudge (empty log only)

If the log is empty after `init` or the first `add`, present a role-aware backfill nudge immediately after the automation table.

**For ICs (default, or `--level eng1/eng2/senior/staff`):**

> **You likely have evidence from this quarter already.** GHE PRs, Jira tickets, and Slack messages from the last 90 days can be pulled into your log now — no manual entry needed.
>
> Run these to populate your log with the current quarter's work:
> 1. `/impact-log add --from ghe` — your authored and reviewed PRs
> 2. `/impact-log add --from jira` — your assigned and reported tickets
> 3. `/impact-log rescue` — Slack threads, Soundcheck, and other evidence approaching retention limits
>
> Would you like to run these now?

<!-- Source ordering mirrors gather.md Level-Weighted Source Priority for EMs -->
**For EMs (when `--level em/sem/director` is configured):**

> **Your impact is in your decisions, coaching, and the outcomes your team delivered.** Google Drive docs, Jira epics, Groove DODs, and Slack recognition threads from the last 90 days can surface evidence of your leadership contributions.
>
> Run these to populate your log:
> 1. `/impact-log add --from drive` (planned) — your 1:1 notes, team retros, meeting notes, and hiring docs. Reference doc not yet written; for now, log these entries manually or use `add` with a Google Doc URL as the source link.
> 2. `/impact-log add --from jira` — epics and initiatives you own, plus tickets you're assigned
> 3. `/impact-log add --from groove-sync` — team-level DODs and bet outcomes
> 4. `/impact-log rescue` — Slack recognition threads about your team members, cross-team coordination
>
> Would you like to run these now?

This is the single highest-value first action for users who install impact-log during an I&DT prep window. They don't have time to manually log months of work entry by entry. The backfill populates the log so `prep` can synthesize it into Workday-ready answers. For EMs, the backfill leads with sources that capture second-order impact (Drive, Groove, Slack recognition) rather than individual contributions (GHE PRs).

Present once on first run to an empty log — not repeated, not tracked (ADR-009). Users who decline proceed to manual entry; the nudge is a prompt, not a gate.

### I&DT awareness in `status` output

Rather than calendar-driven nudges (which would require tracking state across invocations), `prep` and `prep --calibrate` are surfaced contextually in the `status` subcommand output. When the user runs `status` during May/June or December/January, append an I&DT section to the dashboard.

**July cycle (mid-year):**

> **I&DT window:** approaching (June) / open (June 8 – July 3)
> This is the mid-year cycle — self-reflection + conversation only. No Impact Snapshot, no compensation review.
> Run `/impact-log prep` to draft your Workday self-reflection from [N] logged entries.
> Run `prep --calibrate` to self-check with the manager's analytical lens.
> New to this? Open the self-guided walkthrough: `plugins/setup-onboarding/.../impact-and-development-talk-walkthrough/index.html`

**January cycle (year-end):**

> **I&DT window:** approaching (December) / open (dates TBD)
> This is the year-end cycle — includes Impact Snapshot and compensation review.
> Run `/impact-log prep` to draft your Workday self-reflection from [N] logged entries.
> Run `prep --calibrate` to self-check with the manager's analytical lens.
> New to this? Open the self-guided walkthrough: `plugins/setup-onboarding/.../impact-and-development-talk-walkthrough/index.html`

This surfaces only when the user asks for their status (their own action, a relevant moment) — no auto-activation, no marker files, no cross-invocation state. The I&DT window dates and cycle type are read from the cycle-specific section of [`idt-framework-employee.md`](references/idt-framework-employee.md).

### Optional: calendar-driven I&DT nudges (opt-in)

Users who want proactive reminders can enable calendar-driven nudges:

```
/impact-log init --idt-nudges
```

Or toggle in an existing config:

```json
{ "idt_nudges": true }
```

When enabled, any impact-log subcommand invocation during May/December or June/January appends a one-line reminder after the subcommand's normal output:

- **May or December:** `Tip: I&DT prep starts next month. Run status to check pillar coverage.`
- **June or January:** `Tip: I&DT window is open. Run prep to draft your Workday self-reflection.`

Each tip fires once per cycle per tier, tracked via `~/.impact-log/idt-nudge-{cycle}.marker`. This is consent-driven — the user explicitly enables it — and can be disabled at any time by setting `"idt_nudges": false` in config or running `/impact-log init --no-idt-nudges`.

Users who prefer the default (no nudges) get I&DT awareness only through `status` output.

### Why this matters

Users who see only `init` → `add` may assume the skill is manual-only. Surfacing the full source list and the scheduling option on first run sets the correct mental model: the skill can do bulk import and recurring capture, not just one-at-a-time logging. The I&DT awareness in `status` ensures `prep` and `prep --calibrate` are discoverable when they matter most. All discovery follows the [ADR-009 contextual tip pattern](../../../../docs/adr/009-contextual-tip-pattern.md) — presented during a relevant moment, not auto-activated, not tracked.

## Quick start

Three paths, depending on your starting state:

1. **Manual entry (default):** `/impact-log init` → `/impact-log add` for each win as it happens. Manual entry is the default because auto-population requires explicit consent — see *Auto-population: opt-in by design* below.
2. **Auto-populate from a quarterly synthesis:** `/team-update quarterly` (synthesizes Jira / Slack / Drive contributions for the quarter), then `/impact-log add --from quarterly` to fold the highlights into your log. Best on day 1 with an existing quarter to summarize.
3. **Rescue evidence about to expire:** `/impact-log rescue` sweeps Slack, Soundcheck, DevEx, and Content-SIM for items that are within their retention windows but won't be later. Use periodically (e.g., monthly) to catch ephemeral evidence before it falls out — or run `/impact-log schedule install` once to register a recurring cron / launchd entry.

> **Auto-population: opt-in by design.** Per [`docs/privacy-ethics.md`](../../../../docs/privacy-ethics.md), this skill never silently scrapes Jira / Slack / Drive / etc. Auto-populating paths exist (`add --from quarterly`, `rescue`, `add --from ghe`, `add --from jira`) but you invoke them explicitly each time.

> **Pull modes layer on top of tracking sync.** `add --from ghe` and `add --from jira` pull your own contributions from the configured period and surface them as candidate entries to log. They work best when [`/groove-sync`](../../../groove-epic-sync/skills/groove-sync/SKILL.md) (Groove DOD ↔ Jira epic) and [`/sync-prs`](../../../pr-jira-sync/skills/sync-prs/SKILL.md) (PR merged → Jira comment) have run recently — those tracking layers populate the cross-system links that the pull needs. If neither has run in the configured period, the skill prompts you to run them first.

> **Recurring sync:** scheduled recurrence (e.g., a weekly `rescue`) is supported in two paths:
> - `/impact-log schedule` prints the cron line or launchd plist with copy-paste install instructions; you take the `crontab -e` (or `launchctl load`) step yourself.
> - `/impact-log schedule install` writes the entry directly; `schedule dry-run` previews without writing; `schedule remove` cleans up. All three wrap `manage-schedule.sh`, which auto-detects your platform (macOS / Linux / WSL) and runs a health check after install (verifies the entry is loaded). The print-only `schedule` path remains for users who prefer manual install.
>
> **Why local cron / launchd rather than a cloud scheduler?** Many agentic clients offer scheduling primitives, but cloud-hosted schedulers run away from your machine. impact-log's auto-population uses MCP servers (`atlassian-mcp`, `slack-search`, etc.) that authenticate locally with your Spotify SSO. A cloud-side runner doesn't have those credentials or that network path. Local cron / launchd runs where the auth lives, which is why it's the practical scheduled path here. The bundled schedule scripts currently target the Claude CLI; non-Claude users should adapt the runner command before installing a recurring job.

## Log location resolution

The impact log can live in two places:

1. **Home directory:** `~/.impact-log/` — accessible from any project
2. **Current project:** `.impact-log/` in the current working directory

Users may intentionally maintain separate logs (e.g., different teams, different impact cycles) or prefer a single unified log. The skill should not assume which arrangement the user wants.

**On `init`:** Ask the user where the log should live — home directory or current project. Then run squad rubric discovery (see below). Store both preferences in the log's config so subsequent subcommands know which location and rubric to use.

**On any other subcommand:** Check both locations. Then:

- **One log found:** Use it, but mention where it is so the user knows which log they're working with.
- **Both found:** Ask which log to use for this session, and offer to combine them if appropriate.
- **Neither found:** Prompt to run `init`. Do not say "you don't have a log" without checking both locations first.

If the user chooses a location, ask before storing the preference: "Would you like me to save this as your default in `~/.impact-log/config.json` so I don't ask next time?" If they decline, the skill asks on each invocation. The config file is human-readable JSON so the user can inspect and change it directly.

## Squad rubric discovery

Many squads maintain their own impact guide — a document that defines what impact means in the squad's context, what types of outcomes are valued, how HOW behaviors apply to the squad's specific stack, and what each Impact Scale level looks like for the team. These squad rubrics are **additive** — they layer on top of the organizational templates (Performance@Spotify + PZN level templates), not replace them.

The three-layer model:

1. **Performance@Spotify** (base) — WHAT × HOW framework, Values in Action, Impact Scale, 3 Workday questions. Captured in [`idt-framework-employee.md`](references/idt-framework-employee.md).
2. **PZN level templates** (org) — Level-specific dimensions and reflection questions (Eng I through EM). Captured in [`idt-level-templates.md`](references/idt-level-templates.md).
3. **Squad rubric** (additive, optional) — Squad-specific outcome definitions, HOW behaviors, Impact Scale examples, and Expectations Sync questions. Provided by the user via URL.

### Discovery flow (on `init` or first `prep`)

**Step 1 — Ask permission to search.** Before querying any external source, ask:

> Many squads maintain their own impact guide that defines what impact looks like in your team's specific context. Would you like me to search Google Drive for your squad's impact rubric, or do you have a URL to provide?
>
> - Search Google Drive for my squad's impact guide
> - I have a URL (paste it)
> - Skip — use only the organizational templates

If the user chooses "Search Google Drive" and `google-drive-mcp` is configured, search for squad-level rubric docs matching patterns like "[Team Name] Impact Guide", "Performance & Impact in [Team Name]", "[Team Name] Impact Rubric". Use the team name from the user's Groove context or Backstage component ownership if available. If the user provides a URL, skip directly to Step 3.

**Step 2a — If search finds a match:** Present the discovered doc(s):

> I found a squad-level impact guide: **[Turntable Impact Guide](url)**. Would you like to layer it on top of the organizational templates? This adds your team's specific outcome definitions, HOW behaviors, and Impact Scale examples to your prep flow — without replacing the Performance@Spotify framework.
>
> - Yes, use this as my squad rubric
> - No, use only the organizational templates
> - I have a different doc (paste URL)

**Step 2b — If not found:** Ask directly:

> Does your squad have an impact rubric or guide doc? Many teams have one — it defines what impact looks like in your squad's specific context. If you paste the URL, I'll layer it on top of the organizational templates to tailor your reflection questions.
>
> - Paste URL
> - Skip — use only the organizational templates

**Step 3 — Store in config:**

```json
{
  "squad_rubric": "https://docs.google.com/document/d/...",
  "squad_rubric_name": "Turntable Impact Guide"
}
```

The URL is stored so future `prep` runs pick it up automatically. Users can update or remove it by editing `config.json` or running `init` again.

### How `prep` uses the squad rubric

When a squad rubric is configured, the `prep` interactive flow (see [`prep-interactive-flow.md`](references/prep-interactive-flow.md)) reads it at inference time and uses it to:

1. **Enrich reflection questions** — Step 2's deepening prompts incorporate the squad's outcome definitions. For example, if the Turntable Impact Guide defines "platform reliability" as an outcome category, the prompt asks about DJ uptime and incident response alongside the generic Business Impact dimension.
2. **Contextualize HOW** — The squad's specific HOW behaviors (e.g., "validating changes with A/B tests across 80+ markets" for Turntable) are woven into the Values in Action prompts in Step 3.
3. **Ground Impact Scale examples** — If the squad rubric defines what each Impact Scale level looks like for the team, `prep --calibrate` uses these team-specific examples alongside the organizational definitions.
4. **Inform strategic alignment** — The squad's "what we own" and "how our work connects to broader goals" sections provide context for the Prompt 3 strategic alignment question.

The squad rubric is read fresh on each `prep` invocation (not cached) so edits to the source doc are reflected immediately.

### Privacy

- The skill reads the squad rubric doc only when the user has explicitly configured it (consent via `init` or manual config edit)
- The doc URL is stored locally in the user's config, not transmitted elsewhere
- Discovery search (Step 1) uses `google-drive-mcp` which operates under the user's own Google auth scope — it can only find docs the user already has access to

## Strategic alignment field

The `Strategic alignment` column is optional — some work doesn't have a clean tie-in to a named strategic priority. However, a consistently blank field leaves interpretation to the reader. Actively looking for alignment helps the IC articulate the connection between their work and the broader context.

When adding an entry, search for strategic alignment before leaving the field blank:

1. **Check Groove** (if `groove-mcp` is configured) — query the team's DODs for the current period and match the entry's work against DOD titles and descriptions
2. **Check the team's Strategy & Scope doc** (if a link is available in the log config or prior entries) — match against workstream titles
3. **Check Jira Epic** — if the entry links to a Jira ticket, check its Epic's strategy context (populated by `/groove-sync`)
4. **If no named priority found** — consider whether the work contributes to a recognized non-bet impact category: tech health, incident management, on-call reliability, community contributions, mentoring, or cross-team support. These are all meaningful impact in the Performance@Spotify framework. Suggest the specific category (e.g., "Tech Health", "Reliability", "Incident Management", "Community") as the alignment rather than leaving the field blank. The `/utility impact-roi` skill can estimate value for any non-bet category — run `/utility impact-roi estimate "<title>"` inline for a quick estimate, or `/utility impact-roi` for a full analysis.
5. **If the work is on a feature in the finding product-market fit (PMF) phase** — if the entry describes a feature that targets a specific segment before scaling broadly, suggest "Finding PMF — [feature name]" as the alignment. This is a recognized phase in the [Feature PMF Measurement Framework](https://docs.google.com/document/d/1KwTk4QkBnRuzTWNghojWV5KVVB2KjebyL7ttWZMdXR4/) adopted by Sessions Studio. See `/utility pmf-profile` for the full profile template.
6. **If genuinely no alignment** — note "No direct strategic tie-in" rather than leaving the field silently empty. This distinguishes intentional from accidental omission.

## Product-market fit (PMF) stage detection at `add` time

When the entry title or outcome description contains signals suggesting the work is on a feature in the finding-PMF phase, surface a contextual tip (ADR-009 pattern — presented once per entry, not tracked, no suppression counter).

**Signal words/phrases** (check title + outcome):
- "pilot", "beta", "early adopters", "employee-only", "employee testing"
- "small segment", "power users", "launched to a subset"
- "finding fit", "PMF", "product-market fit"
- "the numbers are small but", "low WAU", "niche but engaged"

**Tip (if signals detected):**

> This work appears to be on a feature in the finding product-market fit (PMF) phase. Would you like to frame this entry's outcome using fit-stage dimensions (organic return rate, target segment activation, engagement depth) rather than aggregate metrics? See the [Feature PMF Measurement Framework](https://docs.google.com/document/d/1KwTk4QkBnRuzTWNghojWV5KVVB2KjebyL7ttWZMdXR4/) for the full methodology, or run `/utility pmf-profile` to create a structured profile for this feature.

**If the user accepts:** Reframe the Outcome field to emphasize:
- Target segment activation rate (not total WAU)
- Organic return rate (cadence of return without induced sessions)
- Engagement depth (ratio of core actions to shallow engagement)
- Qualitative signal ("very disappointed" test results if available)

**If the user declines:** Log the entry normally. No follow-up, no counter, no suppression tracking.

## When to use

- "Log this win / shipping moment / outcome before I forget" → `add`
- "I'm coming back to the log after a few weeks — rescue evidence from Slack/Content-SIM/Soundcheck/DevEx before retention closes" → `rescue`
- "What's already in the log this quarter?" → `list` or `status`
- "I just ran `/team-update quarterly` — fold the highlights into my impact log" → `add --from quarterly`
- "I just ran `/groove-sync` — fold the Goal/Strategy/Metrics from my DODs/Epics into my impact log" → `add --from groove-sync`
- "I need to prepare my self-reflection for my Impact & Development Talk" → `prep`
- "I want to check my self-reflection before submitting to Workday" → `prep --calibrate`
- "I'm preparing for an Expectations Sync / Impact Session with my manager" → `prep` (Sections 1-2 of the Expectations Sync agenda map directly to the prep flow; `add --from groove-sync` populates context for Section 1)
- "I led an incident / spent a week on-call / did work that doesn't tie to a bet" → `add` (use non-bet categories like Incident Management, Reliability, Community — see [`idt-framework-employee.md`](references/idt-framework-employee.md) § Non-Bet Contributions)
- "Demo this for an audience" / "Let's do a live demo" → read [`demo-flow.md`](references/demo-flow.md) in live demo mode (narrate + pause between steps + fallback if blocked)
- "Dry-run the demo" / "Rehearse the demo" / "Walk me through the impact-log workflow" → read [`demo-flow.md`](references/demo-flow.md) in tutorial mode (narrate + continuous flow + report issues at end)

For the synthesis side (I&DT self-reflection, quarterly summaries), use `/impact-log prep` for Workday-ready I&DT output, or `/team-update quarterly` for broader quarterly synthesis. This skill covers both *capture* and *I&DT prep*; `/team-update` is the *broader synthesis* side.

## Common flows — what to do next

After each subcommand finishes, the natural next move is usually one of:

| Just ran | Common next step |
|---|---|
| `init` | `add` (first win) — or `add --from quarterly` if you have a quarter to bulk-import |
| `add` | Keep adding as wins happen; `status` periodically to see Pillar / Sub-area gaps |
| `add --from quarterly` | Review imported entries; `update <id>` to refine outcome wording or add AI-accountability notes |
| `rescue` | Review surfaced items; `add` the ones worth keeping; let the rest go |
| `status` | Use gap callouts to drive your next `add` — surfaces Pillars / Sub-areas without entries |
| `list` | Skim entries; `update <id>` to revise; `persist` if it's been a while |
| `persist` | Continue capturing as wins happen — persistence is repeated, not one-shot |
| `prep` | Review the Workday-ready output; edit before submitting. `prep --calibrate` for a self-check with the manager's analytical lens |
| `prep --calibrate` | Review the calibration flags; address any before submitting. Re-run `prep` to regenerate if you add entries |
| `schedule` | Run the printed install command yourself, **or** use `schedule install` to write directly; revisit `status` next month to confirm rescue is firing |
| `schedule install` | Done — health check confirms the entry is loaded. Revisit `status` next month to confirm rescue is producing entries |
| `schedule remove` | Done — entry removed. Run `schedule install` again later if you want recurrence back |

## Why a standalone plugin rather than a subcommand of an existing one?

Two related sub-questions: why a separate skill (vs. folding into an adjacent skill), and why a top-level plugin (vs. living inside `/utility`).

### Why not fold into an adjacent skill?

Per the [ADR-005](../../../../docs/adr/005-skill-to-skill-consolidation.md) consolidation review, the closest adjacent surfaces are `/team-update quarterly`, `/groove-sync`, and `/utility strategy-scope`:

- **vs `/team-update quarterly`** — `/team-update quarterly` *synthesizes* contributions across GitHub / Jira / Drive at a single moment in time (reading). Impact-log *accumulates* structured evidence ongoing (writing). They chain naturally (capture → synthesis), but they're different lifecycle moments and different mental models.
- **vs `/groove-sync`** — `/groove-sync` pushes structured DOD/Epic data into Groove for the team's planning system. Impact-log is *personal* evidence that may compose with Groove output but lives in the user's own log, not in Groove. Different audiences (team-public vs personal-private), different sources of truth.
- **vs `/utility strategy-scope`** — `/utility strategy-scope` produces a forward-looking planning artifact for SteerCo. Impact-log captures *backward-looking* evidence of what was delivered. Opposite directions of the same lifecycle.

### Why a top-level plugin and not a `/utility` subcommand?

Per [ADR-012 §7](../../../../docs/adr/012-routing-layer-as-canonical-catalog-surface.md) (Sessions-native plugin organization), three options were sketched: disperse into existing routing layers (e.g., `/utility impact-log`), consolidate into a new `/sessions-team-tools` plugin, or keep each Sessions-native skill as its own plugin (the hybrid). The chosen path matches every other Sessions-native plugin's structure (`seshgen-taps`, `groove-epic-sync`, `sessions-team-snapshot`, `pr-jira-sync` — each its own plugin), giving impact-log:

- **A top-level entry in `marketplace.json`** so users browsing the marketplace see it alongside the other Sessions-native plugins
- **Its own README** as the front door for discoverability and consent-model docs
- **Independence from `/utility`'s scope** — impact-log is consent-isolated personal data per [ADR-009](../../../../docs/adr/009-contextual-tip-pattern.md); putting it under the catch-all routing layer would dilute that boundary

The marketplace target is ~20 plugins ([ADR-007 Amendment 1](../../../../docs/adr/007-hierarchical-skill-resolution.md#amendments)). The Sessions-native plugins (impact-log, `seshgen-taps`, `groove-epic-sync`, `sessions-team-snapshot`, `pr-jira-sync`) all share this top-level shape, putting the catalog modestly above target. [ADR-012 §7](../../../../docs/adr/012-routing-layer-as-canonical-catalog-surface.md) sketches the path back to ≤20: three options that each consolidate or disperse the Sessions-native plugins, with the choice held for Sessions-team alignment.

## What v0.1 does

Three responsibilities:

1. **Capture** — `add` and `add --from <source>` log structured work examples (Pillar, Sub-area, Outcome, AI accountability, blast radius, source link).
2. **Rescue** — `rescue` sweeps ephemeral sources (Slack 90d, Content-SIM ~90d, Soundcheck 30d API window, DevEx ~13w) for evidence that's about to fall out of retention.
3. **Persist** — `persist` writes the log to a destination of your choice (personal private GitHub repo / Google Doc / local directory).

## Subcommands (v0.1)

| Subcommand | Phase | Purpose |
|------------|-------|---------|
| `overview` | Setup | Print the three-step flow and the most common subcommand sequences. **Returning user detection:** if an existing `.impact-log/` directory is found, examines the config for missing features (e.g., no `career_level` field, no `schema_version`) and surfaces new capabilities relevant to the user's I&DT cycle phase. See [Returning Users](#returning-users). |
| `init` | Setup | Create local `.impact-log/` directory; choose persistence target (GitHub repo / Google Doc / local); scaffold from the V1 template; optionally select a career-level prep template (Eng I / Eng II / Senior / Generic / custom). **Upgrade detection:** if `.impact-log/` already exists, offers "upgrade config (preserve entries, add new features)" vs "start fresh" — never silently overwrites. |
| `add` | Log | Log one work example: Pillar, Sub-area, Date, Title, Outcome (WHAT changed?), AI accountability (validated how?), Blast radius / speed calibration, Source. When a career level is configured, the third pillar uses the level-appropriate label (e.g., "Contributing to the Team" for Eng I/II, "Enabling Others" for Senior) instead of the generic "Culture & Organization." |
| `add --from quarterly` | Log | Import structured highlights from `/team-update quarterly` output |
| `add --from groove-sync` | Log | Import Goal / Strategy / Metrics from `/groove-sync` output for DODs you own |
| `add --from ghe` | Log | Pull your own GHE PRs from the configured period and surface them as candidate entries to log. Consent-isolated to PRs authored, reviewed, or commented on by you. See [`pull-ghe.md`](references/pull-ghe.md). |
| `add --from jira` | Log | Pull your own Jira contributions from the configured period (assigned, reported, or commented) and surface them as candidate entries. See [`pull-jira.md`](references/pull-jira.md). |
| `rescue` | Log | Sweep ephemeral sources for evidence about to expire |
| `rescue --source <name>` | Log | Targeted rescue from one source |
| `rescue --dry-run` | Log | Preview what would be found without creating entries |
| `list` | Log | Show entries; filter by `--quarter`, `--pillar`, `--sub-area` |
| `update <id>` | Log | Edit a specific entry |
| `status` | All | Dashboard: entry count, gap by pillar (using level-appropriate dimension names when `career_level` is configured), rescue freshness, days since last entry. During May/June or Dec/Jan, includes I&DT awareness section surfacing `prep` and `prep --calibrate`. |
| `prep` | I&DT | Interactive coached self-reflection → Workday-ready answers (3 questions, 500 chars each). 7-step flow: select top outcomes, deepen with discovery mode (MCP-sourced evidence from Oliver, Lineage, Groove, Slack), surface the HOW, calibrate, draft. See [`prep-interactive-flow.md`](references/prep-interactive-flow.md). |
| `prep --calibrate` | I&DT | After drafting, run the manager's analytical lens against your own output: bias checks (activity trap, comfort trap, HOW missing, thin input), bright spots vs outliers, expectations gap check, edge presence. When a career level is configured, bias checks use level-appropriate framing (e.g., "HOW missing" checks for engagement evidence at Eng I vs enabling-others evidence at Senior). See [`idt-framework-manager.md`](references/idt-framework-manager.md). |
| `prep --level <level>` | I&DT | Use level-specific reflection questions: `eng1`, `eng2`, `senior`, `staff`, `em`, `sem`, `director`, or `custom --template <path>`. Falls back to `career_level` in config.json, then to the generic framework. See [`idt-level-templates.md`](references/idt-level-templates.md) and [`role-coverage.md`](references/role-coverage.md) for the full map of supported roles, planned roles, and source material. |
| `prep --quarter <Q>` | I&DT | Scope the prep to a specific quarter (default: current quarter). Combines with `--calibrate` and `--level`. |
| `persist` | Persist | Push to configured persistence destination |
| `persist --to github` | Persist | Push to a personal private GitHub repo |
| `persist --to gdoc` | Persist | Append to a configured Google Doc |
| `persist --to gsheet` | Persist | Append to a configured Google Sheet (use `gworkspace-write.sh --sheets-create-from-csv references/template-impact-log.csv` to bootstrap one) |
| `persist --to local` | Persist | Export to a local directory |
| `schedule` | Setup | Print a cron / launchd entry for recurring `rescue` (or any other subcommand). The skill prints; you install with `crontab -e` or `launchctl load`. |
| `schedule --subcommand <sub>` | Setup | Schedule a different subcommand (default: `rescue`) |
| `schedule --cadence <weekly\|monthly>` | Setup | Choose the cadence (default: `weekly`). Pass a literal cron expression for custom timing. |
| `schedule --platform <auto\|cron\|launchd>` | Setup | Force a specific platform (default: auto-detect from `uname`) |
| `schedule install` | Setup | Write the entry directly to crontab (Linux/WSL) or `LaunchAgents/` (macOS) and verify it's loaded. Wraps `manage-schedule.sh --action install`. |
| `schedule dry-run` | Setup | Preview the planned install without writing. Wraps `manage-schedule.sh --action dry-run`. Run before `schedule install` if you want to confirm the entry first. |
| `schedule remove` | Setup | Remove the previously-installed entry (matched by subcommand identifier). Wraps `manage-schedule.sh --action remove`. |
| **Cadence** | | |
| `gather` | Weekly | Accumulate contributions from all configured MCP sources (GHE, Jira, Drive, Oliver, Groove, Slack) into a weekly block. 8-step checklist with completeness self-check. Append to monthly contributions file. See [`gather.md`](references/gather.md). |
| `gather --backfill` | Weekly | Run `gather` for a past period (catching up after time off). Same 8 steps with date range override. |
| `synthesize` | Monthly | Rewrite weekly blocks into a grouped narrative: epic-based clustering, DELIVERY/INFLUENCE classification, business context enrichment, pillar coverage. Transform-only — no MCP calls. See [`synthesize.md`](references/synthesize.md). |
| `compile` | Biannual | Long-form I&DT document: Looking Back / Right Now / Looking Ahead from monthly syntheses. Includes private conversation prep and Workday summary draft. See [`compile.md`](references/compile.md). |
| **Feedback collection** | | |
| `feedback-request peer` | Per cycle | Collect peer feedback about you. Setup wizard copies a role-appropriate template form, tracks recipients, sends initial ask + reminders via Slack DM, detects submissions from the response spreadsheet. See [`feedback-request.md`](references/feedback-request.md). |
| `feedback-request manager-eval` | Per cycle | Collect your manager's evaluation of you. Same workflow as peer, different form template and message wording. |
| `feedback-request upward` | Per cycle | (EM) Collect upward feedback from your direct reports about you as their manager. |
| `feedback-request draft` | Per peer | Coach yourself through writing peer feedback via reflective prompts. Produces a local draft organized by dimension (growth, technical, collaboration, leadership). The tool prompts; you write. See [`feedback-request-draft.md`](references/feedback-request-draft.md). |

## Outputs and lifecycle

The log is a living document for one IC or EM over an impact cycle. It captures meaningful work moments — shipped deliveries, learnings that reshaped a plan, postmortem insights, scoping decisions, and *valuable failures* (experiments that disproved a hypothesis, abandoned approaches that surfaced insight) — and persists to a destination chosen at `init` time (GitHub private repo, Google Doc, Google Sheet, or local directory). At I&DT time, use `prep` to draft Workday-ready self-reflection answers; for broader quarterly synthesis, use `/team-update quarterly`.

See [`references/outputs-and-lifecycle.md`](references/outputs-and-lifecycle.md) for the full reference: entry shape, sample entries across roles and outcome types, persistence destinations, when to run each subcommand across the cycle, and what you walk away with at the end.

## Framework: Engineering Expectations + Performance@Spotify

The impact log is aligned to two complementary frameworks:

1. **Engineering Expectations in an AI Era** ([XTL doc](https://docs.google.com/document/d/12o2AVnHKmALOqMPaFIZmO2LuNSwatbYBJ8lrKfoZ5xI/)) — 3 Pillars (Business Impact, Technical Excellence, Culture & Organization) with 9 sub-areas, mapped to 7 career levels (Associate → Principal). This shapes the `add` entry structure (Pillar / Sub-area / Outcome).

2. **Performance@Spotify** ([playbook](https://docs.google.com/presentation/d/1i0p_sQRPPq1SrHqXrs0Wfs3BAbH2tK8K8GyQ7c5fKB4/)) — defines Performance = WHAT x HOW, with HOW expressed through three Values in Action (One Team, Human Judgement, Make It Happen). This shapes the `prep` output (Workday-ready self-reflection mapped to the 3 I&DT questions).

3. **Level-specific templates** ([`idt-level-templates.md`](references/idt-level-templates.md)) — optional, career-level-tailored reflection dimensions and questions (Eng I, Eng II, Senior Eng, with Staff and EM placeholders). Each level defines three impact dimensions with level-appropriate framing and reflection questions. Users can also provide their own custom template.

The `prep` subcommand bridges these: it reads entries structured by Engineering Expectations, applies level-specific reflection questions (if configured via `--level` or `career_level` in config.json), and maps them to the Performance@Spotify output format for Workday submission. See [`idt-framework-employee.md`](references/idt-framework-employee.md) for the framework reference and [`idt-level-templates.md`](references/idt-level-templates.md) for level-specific prompts.

The template defines the columns each entry captures:

| Column | Source |
|--------|--------|
| Pillar | Business Impact / Technical Excellence / Culture & Organization |
| Sub-area | One of 9 (3 per pillar) |
| Date | When the work shipped |
| Title | Short label for the entry |
| Outcome | WHAT changed for users / business / team — written as an outcome, not an activity |
| AI accountability | If AI assistance was used, how was the output validated? |
| Blast radius / speed calibration | Reversible quick iteration vs. high-stakes rigor |
| Source | Link to PR / Doc / experiment / Slack thread |
| Strategic alignment (optional) | Link to the Tech Strategy, Company bet, OKR, or SteerCo doc this work advanced. Leave blank when there's no clean tie-in. |

Two starter templates ship in `references/`:

- [`template-impact-log.md`](references/template-impact-log.md) — markdown-block format for `--to local` and `--to github`. Append new entries at the end.
- [`template-impact-log.csv`](references/template-impact-log.csv) — header-only CSV used by `--to gsheet` to bootstrap a fresh user-owned Google Sheet via `gworkspace-write.sh --sheets-create-from-csv`.

For `--to gdoc`, the local markdown template is uploaded as a Google Doc on the first `persist`.

## Returning Users

When a user invokes impact-log and an existing `.impact-log/` directory is found, the skill examines the config structure to surface relevant new features without tracking user behavior.

### How it works (Tier 1: structural detection with transparency)

The skill checks the existing `config.json` for the presence or absence of fields added in later versions. Before making any suggestions, it **explains what it detected and why**:

> "I found your existing impact-log config. It was created with an earlier version of the skill — I can tell because it's missing some fields that were added in later versions. Here's what I noticed:"

Then it presents all detected changes as a summary with per-item approval:

| Missing field | Added in | What it enables | Default |
|---------------|----------|----------------|---------|
| `career_level` | v0.2 | Level-specific I&DT prep via `prep --level senior` | Ask user to choose level |

Note: `schema_version` is handled separately in Tier 2 (opt-in version tracking) because it involves a consent decision about ongoing version tracking, not just a one-time config addition.

**Presentation:** When multiple fields are missing, present them together as a checklist rather than asking one at a time:

> "I found your existing impact-log config. It was created with an earlier version — here's what I noticed:
>
> 1. No `career_level` set — this enables level-tailored Workday drafts via `prep --level`
> 2. _(additional missing fields listed here if applicable)_
>
> Would you like to apply these updates? You can accept all, select individually, or skip."

The user can:
- **Accept all** — apply all suggested changes at once
- **Select individually** — review and approve/decline each change
- **Skip** — make no changes; the skill continues normally with Tier 1 informational suggestions only

No changes are made without explicit approval. Declining leaves the config unchanged for that field.

The skill also checks the I&DT cycle phase (May/June or Dec/Jan) and surfaces time-sensitive features as informational suggestions (no config changes):

- During I&DT prep window: "New since your config was created: `prep --level` for level-tailored Workday drafts, `prep --calibrate` for manager-lens self-check"
- If log has few entries: "You can backfill quickly with `add --from ghe` (your PRs) and `add --from jira` (your tickets)"
- If feedback-request state files don't exist: "New: `feedback-request peer` to collect peer feedback via forms + Slack reminders"

### How it works (Tier 2: opt-in version tracking)

After Tier 1 config changes are resolved, if the config still has no `schema_version`, the skill asks:

> "Would you like the skill to track which version produced your config so it can offer targeted upgrade guidance on future runs? This stores a version stamp in your local config file. You can disable this anytime by running `init --reconfigure` or setting `version_tracking_consent: false` in config.json."

| Consent | Config change | Effect |
|---------|--------------|--------|
| **Accept** | `schema_version` + `version_tracking_consent: true` | Skill surfaces new features based on version delta |
| **Decline** | `version_tracking_consent: false` | Tier 1 structural detection still works; less specific suggestions |
| **Change mind** | Edit `config.json` or run `init --reconfigure` | Fully reversible |

Neither tier records run timestamps, session counts, feature usage, or inactivity signals. No server-side telemetry — everything stays in the user's local config file.

### `init` upgrade behavior

When `init` detects an existing `.impact-log/` directory:

1. Show: "Found existing impact-log config with N entries."
2. Offer two paths:
   - **Upgrade** (default): preserve all entries and config, add missing fields from the current version, optionally set `career_level` if not present
   - **Fresh start**: back up existing directory to `.impact-log.backup/`, create new config from scratch
3. Never silently overwrite.

## Composition with adjacent skills

| Skill | How impact-log composes with it |
|-------|--------------------------------|
| [`/team-update quarterly`](../../../team-update/skills/team-update/SKILL.md) | Run `/team-update quarterly` to synthesize a quarter's contributions; pipe highlights back via `/impact-log add --from quarterly` |
| [`/groove-sync`](../../../groove-epic-sync/skills/groove-sync/SKILL.md) | Pull AI-generated Goal/Strategy/Metrics from your DODs into your personal impact log via `/impact-log add --from groove-sync` |
| [`/utility strategy-scope`](../../../utility/skills/utility/references/strategy-scope.md) | Use forward-looking strategy/scope context as a frame for backward-looking impact-log entries |
| [`/google-workspace`](../../../google-workspace/skills/google-workspace/SKILL.md) | Used by `persist --to gdoc` to append entries to a Google Doc |
| [`/agent-behavior`](../../../utility/skills/agent-behavior/SKILL.md) | Already surfaced in the Unified AI Marketplace via `/agent-behavior register`. Once impact-log graduates from `lifecycle: experimental`, the lifecycle field updates automatically on the next register run. |
| [`/utility impact-roi`](../../../utility/skills/utility/references/impact-roi.md) | Estimate ROI of non-bet work inline during `add` (compact estimate appended to entry) or during `prep` discovery mode (quantitative enrichment). Run `/utility impact-roi --from impact-log` for batch analysis across all non-bet entries. |
| [`/utility pmf-profile`](../../../utility/skills/utility/references/pmf-profile.md) | Reference the feature's product-market fit (PMF) Profile when logging work on a feature in the finding-PMF phase. The profile's target segment and organic usage definition help frame the entry's outcome in fit-stage terms. |
| [`/google-workspace forms`](../../../google-workspace/skills/google-workspace/SKILL.md) | `feedback-request` setup wizard uses `/google-workspace forms clone` to programmatically copy template forms into the user's Drive when available |
| `impact-dev-talk-employee` (claude.ai Skill) | Complementary: the claude.ai Skill coaches self-reflection writing from scratch or reviews pasted drafts. Impact-log's `prep` subcommand starts from logged evidence and produces the same Workday-ready output. Users can use either or both. |
| `impact-dev-talk-manager` (claude.ai Skill) | The manager skill's analysis framework (alignment/divergence, bias checks) is captured in [`idt-framework-manager.md`](references/idt-framework-manager.md) and used by `prep --calibrate` for IC self-assessment. Available to all employees via claude.ai. |

## Privacy considerations

- Impact-log entries are **personal** — they capture *your* contributions, not your teammates'. Do not log evidence about other people's work without their explicit consent.
- Slack rescue (`rescue --source slack`) reads only public channels and DMs you're a member of. Private channel content carries elevated sensitivity — review what's surfaced before persisting to a shared destination.
- `persist --to gdoc` writes to a Google Doc owned by you (or a destination you specify). Sharing scope of that Doc is your decision.
- The skill does not transmit log content anywhere except destinations you explicitly configure via `persist`.

## Status

- **v0.10.1 (this version):** Cross-model compatibility fix for Codex and other non-Claude agents: move compatibility notes into `metadata.compatibility`, document slash-command syntax as intent labels outside Claude Code, and clarify that scheduled runs are currently Claude CLI-specific.
- **v0.8:** All of v0.7, plus returning user upgrade guidance: two-tier detection (Tier 1 structural detection always active, Tier 2 opt-in version tracking with explicit consent). Enhanced `overview` and `init` subcommands to detect existing data and surface new features for returning users. Privacy-respecting: no silent tracking, no degradation on decline.
- **v0.7:** All of v0.5, plus `feedback-request` subcommand — consolidated from Ilya Kaplun's feedback-reminders and manager-feedback-reminders skills. Three collection flows: `peer`, `manager-eval`, `upward` (setup wizard, 3-stage reminders, submission detection). Plus `feedback-request draft` — guided peer feedback writing via reflective prompts, producing a local draft organized by dimension. The tool coaches your thinking; it never writes on your behalf or accesses your peer's data.
- **v0.5:** All of v0.4, plus EM experience parity: EM-specific pull modes and Jira queries (epics, initiatives, pair/mob), EM discovery sources and deepening prompts in `prep`, role-aware backfill nudge, `prep --calibrate` EM anti-patterns (team-outcome-without-attribution, execution-depth, invisible-coaching), derived Senior EM and Director templates, organizational role coverage map, `add --from drive` (planned), and post-rebase version bump gap documentation.
- **v0.4:** All of v0.3, plus `gather` (weekly 8-step contribution accumulation from MCP sources), `synthesize` (monthly narrative with DELIVERY/INFLUENCE classification), `compile` (biannual Looking Back / Right Now / Looking Ahead with Workday summary). Cadence workflows adapted from contribution-tracker and dev-talk-report skills (smercier).
- **v0.3:** All of v0.2, plus Staff Eng and EM templates, Impact Scale, Impact Rhythm, Non-Bet Contributions, second-order impact framing, July vs December cycle awareness, squad rubric discovery, per-level evidence signals, `/utility impact-roi` composition.
- **v0.2:** capture, rescue, persist, prep (interactive coached I&DT self-reflection with discovery mode), prep --calibrate (manager-lens self-check), level-specific templates (Eng I / Eng II / Senior / custom); Engineering Expectations + Performance@Spotify framework; experimental.
- **v0.1:** capture, rescue, persist; Engineering Expectations framework only.
- **Future:** Additional role templates (Senior Staff, Principal, Senior Director, VP, PM, DS, UR). Promotion to `lifecycle: production` will register the skill in the Unified AI Marketplace via `/agent-behavior register`.
