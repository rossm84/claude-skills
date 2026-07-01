# `prep` — Interactive Self-Reflection Flow

Reference for `/impact-log prep`. Describes the 7-step coached flow that guides the user through drafting Workday-ready self-reflection answers from their impact-log entries. Each deepening step offers **discovery mode** — the agent searches MCP sources for quantitative evidence the user can incorporate.

The flow applies the coaching quality of the official `impact-dev-talk-employee` claude.ai Skill (coaching reactions, probing for depth, pre-output calibration) to the data-enriched context of impact-log (logged entries, MCP-sourced evidence). See [`idt-framework-employee.md`](idt-framework-employee.md) for the framework reference and quality checks.

---

## Step 1 — Select your top outcomes (Q1 focus)

Present the quarter's impact-log entries as `AskUserQuestion` multiSelect options, grouped by pillar. The user picks the 2-3 that mattered most.

- header: `Top impact`
- question: `Which 2-3 outcomes mattered most this quarter? These will anchor your self-reflection.`
- options: entries with title + outcome preview, organized by pillar (Business Impact, Technical Excellence, Culture & Organization)

If the log has more than 4 entries per pillar, show the 4 with the strongest outcomes (longest outcome text, most source links) and rely on the auto-"Other" escape for entries not listed.

If the log is empty or has fewer than 3 entries, skip this step and prompt the user to add entries first — or offer to run the backfill (`add --from ghe`, `add --from jira`, `rescue`).

---

## Step 2 — Deepen each selected outcome (iterative)

For each selected entry, probe for the three impact dimensions from the Performance@Spotify framework. Before each question, offer discovery mode.

### Discovery mode (optional per question)

Ask via `AskUserQuestion`:

- header: `Research`
- question: `Want me to search for evidence to strengthen this answer?`
- options:
  - `Yes, search for evidence` — "I'll query connected tools for quantitative data, feedback, and strategic context."
  - `No, I'll answer from memory` — "Skip the search and move straight to the reflection question."

If the user chooses discovery, query MCP sources based on the entry's context:

| Entry context | Signal | MCP sources queried | Evidence surfaced |
|---|---|---|---|
| Source link is a PR URL | GHE PR | GHE: PR details, files changed, reviews | Code change scope, cross-repo impact, reviewer count |
| Source link contains a Jira key | Jira ticket | Groove: `list-epics` -> `get-work-item-context` -> `get-initiative` | DOD -> initiative -> bet alignment chain |
| Title or outcome mentions "experiment" or an EP ID | Experiment | Oliver: `get_experiment_results`, `get_experiment_exposures` | Metric deltas, exposure count, ship decision, hypothesis |
| Pillar is Technical Excellence + sub-area is Reliability | Reliability work | Oliver: `list_slos`, `get_slo`, `get_component_metadata` | SLO compliance, error budget, dependency fan-out |
| Pillar is Business Impact | Data or pipeline work | Lineage: `get_summary`, `analyze_usage` | Consumer reach (accesses, users, teams over 30d) |
| Any entry | Feedback and recognition | Slack: `slack_search_public` for the entry's title or topic | Praise, feedback threads, cross-team coordination |
| Strategic alignment is blank | Missing alignment | Groove: `list-epics` for the team's current period | DODs/initiatives to suggest as alignment |
| Strategic alignment is a non-bet category (Tech Health, Incident Management, On-call, Community, Mentoring, Cross-team, Process) | Non-bet work | `/utility impact-roi` estimation heuristics + available MCP sources per [methodology.md](../../../../utility/skills/utility/references/impact-roi/methodology.md) | Estimated ROI value (compact format) with confidence level and methodology citation |

Present discoveries as a brief summary with source links (2-4 bullets, not a data dump). The user picks which findings to incorporate. Discovery results are suggestions, not assertions.

**Level-weighted source priority:** When a career level is configured, discovery mode prioritizes sources by relevance to that level. All sources remain available — the weighting affects which sources are proactively suggested when the entry's context doesn't point to a specific source.

| Source | Eng I/II | Senior+ | EM |
|---|---|---|---|
| Slack (recognition, feedback) | High | Medium | Medium |
| Slack (recognition of team members, cross-team coordination) | Low | Low | High |
| GHE (code review received) | High | Low | Low |
| GHE (reviews given, mentoring signals) | Low | High | Medium |
| Oliver (experiments, SLOs, component metadata) | Low | High | High |
| Lineage (consumer reach) | Low | High | Low |
| Groove (DOD/initiative alignment) | Low | High | High |
| Groove (team-level DODs, bet delivery) | Low | Low | High |
| Google Drive (1:1 notes, team retros, meeting notes) | Low | Low | High |
| Google Drive (hiring docs, onboarding plans) | Low | Low | High |

If the entry's context signals a specific source (e.g., an experiment ID, a PR URL, a Google Doc link), that source is queried at full weight regardless of level.

**EM-specific discovery notes:** EM impact often shows up in sources that require interpretation rather than direct measurement. Recognition threads about team members (not the EM personally) are evidence of the EM's culture-building impact. 1:1 notes and team retros capture coaching and priority decisions that don't appear in code or tickets. The agent should search these sources proactively for EMs rather than waiting for the entry's context to point to them.

**Privacy: reports' information in EM discovery.** EM discovery surfaces evidence *about* team members to help the EM frame their own leadership contribution. This evidence is context for the EM's self-reflection, not data about the report's performance. The agent must:
- Surface team-level aggregate patterns only — do not attribute specific messages to named individuals
- Use 1:1 notes and coaching outcomes as framing context for the EM's contribution ("my coaching helped this engineer grow from X to Y"), not as evidence about the report
- Never include reports' names, specific feedback, or performance details in `prep` output unless the EM explicitly adds them
- Present all discovered evidence as candidates for the EM to review and selectively incorporate — never auto-include

### Three deepening prompts

For each selected entry, ask these three questions one at a time. After each answer, give a coaching reaction (1-2 sentences reflecting back what the user shared, noting any discovered evidence that supports or extends it).

**When a career level is configured** (via `--level` or `career_level` in config.json), use the level-specific dimensions and reflection questions from [`idt-level-templates.md`](idt-level-templates.md) instead of the generic prompts below. For example, an Eng I sees "Did you understand why the work you delivered mattered?" while a Senior sees "Where did your judgment and initiative shape your squad's direction?" When `--level custom` is set, read the user's template and adapt the prompts to its structure.

**When `--level em` is configured**, use EM-specific deepening prompts that focus on enabling, deciding, and building — not shipping:

**Prompt 1 — Enabling outcome:** "Your log says: *[outcome]*. What would not have happened — or would have happened slower, worse, or not at all — without your involvement? Name the specific people, decisions, or conditions you created that made this outcome possible."

**Prompt 2 — Second-order impact:** "Who grew, what unblocked, or what decision was better because of how you showed up? Can you trace the chain from your action (coaching, priority call, hiring, process change) to the team outcome?"

**Prompt 3 — Strategic framing:** Present team-level Groove DODs and bets as `AskUserQuestion` options. For EMs, the strategic alignment question is: "How did this connect your squad's work to broader studio or organizational priorities?" rather than "Which priority does this connect to?" — EMs are expected to articulate the connection, not just name the priority.

**When no level is configured** (default), use the generic Performance@Spotify dimensions:

**Prompt 1 — Outcome-focused:** "Your log says: *[outcome]*. What does this unlock or enable downstream? If you think six months ahead, how does this compound — for the team, the product, or the organisation?"

**Prompt 2 — Adding value:** "Who benefits from this — users, creators, teammates, the platform? Can you name the specific effect?"

**Prompt 3 — Matters to Spotify:** Present Groove DODs/initiatives as `AskUserQuestion` options for strategic alignment (auto-queried if groove-mcp is configured). If the entry already has strategic alignment, confirm it.

- header: `Strategic alignment`
- question: `Which priority does this work connect to?`
- options: DOD titles from Groove for the current period, plus:
  - `Tech Health` — "Reliability, debt reduction, operational efficiency — a recognized category of impact"
  - `No direct tie-in` — "This work doesn't connect to a named priority and that's fine"

---

## Step 3 — Surface the HOW (Q1 focus, second pass)

After deepening the WHAT for all selected entries, prompt for the HOW dimension.

- header: `Values in action`
- question: `Did anything stand out about how you showed up for [selected outcome]?`
- options:
  - `One Team` — "Synchronised across teams, communicated openly, thought in systems"
  - `Human Judgement` — "Made an informed decision, adapted with awareness, shared knowledge"
  - `Make It Happen` — "Owned the outcome, improved through debate, executed with precision"
  - `Skip` — "The WHAT tells the story here"

If the user selects a value, ask one follow-up: "Can you name a specific moment where that showed up?" This grounds the HOW in a concrete example rather than a generic claim.

---

## Step 4 — Calibrate shortfalls (Q2 focus)

Surface entries that are thin (short outcome, no strategic alignment) or pillars/sub-areas with no entries at all. Present as `AskUserQuestion`:

- header: `Shortfalls`
- question: `Q2 asks where impact fell short. Any of these worth reflecting on?`
- options: up to 3 items drawn from:
  - Entries with thin outcomes (fewer than 20 words in the Outcome field)
  - Pillars or sub-areas with zero entries this quarter
  - Plus: `Something not in the log` — "A shortfall or learning that isn't captured in any entry"

For whatever the user selects, prompt: "What did you learn from this — and has anything changed because of it?"

Apply the "Nothing went wrong" probe from the framework: if the user says nothing fell short, ask directly: "Is there anything that stalled, didn't land, or that you'd approach differently — even if it didn't feel like a failure?"

---

## Step 5 — Growth actions (Q3 focus)

Based on the gaps surfaced in Step 4 and the user's reflections:

- "What's one skill or behaviour that would unlock more impact for you?"
- Probe for impact, not just development: "If you did that — what would it enable that you can't do today?" Frame the answer around the impact that growth would produce, not the development itself.

---

## Step 6 — Pre-output calibration

Before drafting, summarise what's strong vs thin (matching the official claude.ai Skill's pre-output calibration check):

> "Here's my read on where we stand:
> - **Strong:** [1-2 items with concrete evidence or quantitative backing]
> - **Thinner:** [1-2 items where the outcome is lighter or the claim is broader than what was shared]
>
> Does that match your read? Add more substance now, or keep what we have?"

Present as `AskUserQuestion`:

- header: `Calibration`
- question: `[the summary above] — ready to draft, or add more?`
- options:
  - `Draft now` — "Generate the Workday-ready answers from what we have"
  - `Add more to Q1` — "I have more to say about impact"
  - `Add more to Q2` — "I want to reflect more on shortfalls"
  - `Add more to Q3` — "I want to refine my growth actions"

---

## Step 7 — Draft and refine

Produce the Workday-ready block (500 chars per question). Apply the quality checks from [`idt-framework-employee.md`](idt-framework-employee.md) (outcomes vs activities, unique strength, expectations grounding, credibility probe, character limits).

Show character counts: `[423 / 500 characters]`. If over 500, trim before presenting (keep impact claims, trim adjectives/transitions).

Present the full block:

```
What impact did I create?
[final answer text only]

Where did I fall short, and what did I learn?
[final answer text only]

What would it take to create more impact next?
[final answer text only]
```

After the block: "These are a starting point — make sure each one sounds like you before you submit."

Offer one round of revision via `AskUserQuestion`:

- header: `Revise`
- question: `Want to adjust anything before this is final?`
- options:
  - `Looks good` — "Copy-paste ready for Workday"
  - `Revise Q1` — "Adjust the impact answer"
  - `Revise Q2` — "Adjust the shortfalls answer"
  - `Revise Q3` — "Adjust the growth answer"

---

## How sync-prs composes with this flow

The `/sync-prs` skill (PR-to-Jira sync) feeds this flow at two points:

- **At capture time:** After sync-prs runs, entries created via `add --from ghe` or `add --from sync-prs` already have PR URLs, Jira ticket keys, and AI-generated summaries — richer raw material for the reflection.
- **At prep time:** Discovery mode can query GHE for PR details and Groove for Jira-to-DOD alignment using the source links from sync-prs entries. The richer the entry metadata, the more useful discovery mode is.

---

## Schema note: impact evidence field

Discovery mode surfaces quantitative evidence (experiment metric deltas, consumer reach, SLO data) during the `prep` flow, but this data is not persisted back to impact-log entries. The entry schema remains 9 fields; enrichment lives in the `prep` flow's context at synthesis time rather than at capture time.

If users consistently want to persist measurement data back to entries, that is the signal to add an optional **Impact evidence** column to the entry schema — a structured field for quantitative data from MCP sources. This would be an additive, non-breaking change (existing entries without the field remain valid). Evaluate after the first I&DT cycle based on user feedback.
