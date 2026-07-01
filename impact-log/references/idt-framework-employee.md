# I&DT Framework — Employee Self-Reflection

> **Freshness notice**
> - **Accessed:** 2026-06-08
> - **Sources:**
>   - `impact-dev-talk-employee` claude.ai Skill (downloaded from claude.ai/customize/skills)
>   - [Performance@Spotify playbook](https://docs.google.com/presentation/d/1i0p_sQRPPq1SrHqXrs0Wfs3BAbH2tK8K8GyQ7c5fKB4/) (canonical source)
>   - [Workday & Claude companion guide](https://docs.google.com/presentation/d/1j1_54HSyzX-bX8oCNSeMLmVr8GgdEVfcqdDHXrbsXBU/) (step-by-step Workday walkthrough)
>   - [Impact Info Session — PZN](https://docs.google.com/presentation/d/1ZLCUp3iX_wxjtGWE6-57wliKzxq0DghuUdaNHoMOVkg/) (June 2026)
> - This content was captured on the date above and may not reflect the current I&DT cycle. Check the canonical sources or re-download the claude.ai Skill for updates.

---

## Performance Framework

**Impact** is the value work creates for the team, organisation, and Spotify. Three dimensions:

- **Outcome-focused** — what changed or improved as a result; not just activity
- **Adding value** — creates real, observable value for users, creators, customers, or Spotify teams
- **Matters to Spotify** — advances Spotify's strategies or org priorities

### Performance = WHAT x HOW

Both count equally.

**WHAT** = the outcomes and results delivered

**HOW** = how the work was done, through Spotify's three values:

| Value | What it looks like |
|-------|-------------------|
| **One Team** | Synchronise broadly, communicate openly, think in systems |
| **Human Judgement** | Make informed decisions, adapt with awareness, share knowledge generously |
| **Make It Happen** | Own the outcome, improve through debate, execute with precision |

### Expectations Grounding

**Agreed expectations** are set through Expectations Syncs — quarterly conversations where manager and bandmate align on what impact looks like. The I&DT is anchored in those expectations. See [`idt-level-templates.md`](idt-level-templates.md) for the level-specific Expectations Sync agenda (30-minute template with 3 sections: reconnect on priorities, the three big questions, shared commitments).

### Impact Scale

The Impact Scale defines five levels of impact. It is used by managers in the Impact Snapshot assessment (starting January 2027) — it is NOT part of the employee self-reflection in Workday. Understanding it helps frame what "impact" means at different levels.

| Level | Description | Expected distribution |
|-------|-------------|----------------------|
| **Low** | Below the bar; work or behaviors fall short | ~5% |
| **Inconsistent** | Sometimes meets, sometimes not (may be recently hired/promoted) | ~15% |
| **Consistent** | Reliably meets the bar; delivers meaningful outcomes | ~40% |
| **High** | Consistently exceeds the bar; sustained high-quality outcomes | ~30% |
| **Exceptional** | Consistently exceptional, well above the bar | ~10% |

Distribution targets sit at the ETeam/ETeam-1 level (not individual teams) and are described as "a tool, not a quota." See the [Performance@Spotify playbook](https://docs.google.com/presentation/d/1i0p_sQRPPq1SrHqXrs0Wfs3BAbH2tK8K8GyQ7c5fKB4/) (slides 48-58) for detailed per-level WHAT and HOW indicators.

### Impact Rhythm

Impact follows a shared cadence across the year:

| Touchpoint | Cadence | Purpose |
|------------|---------|---------|
| Expectations Syncs | Quarterly | Manager and bandmate align on what impact looks like for the next 3-6 months |
| Impact & Development Talks | Twice yearly (July + January) | Reflection, feedback, growth planning |
| Impact Snapshot | Once yearly (January only, starting 2027) | Manager formally assesses bandmate on the Impact Scale |
| Compensation review | Once yearly (January only) | Tied to Impact Snapshot outcomes |

### Non-Bet Contributions

Not all impact ties to a named bet, OKR, or strategic priority. The following categories of contribution are recognized as meaningful impact and should be captured in your log:

| Category | Examples | How to frame it |
|----------|---------|----------------|
| **Incident management** | Leading incident response, writing postmortems, implementing preventive measures | Outcome: what the incident revealed, what changed because of your response, downstream impact prevented |
| **On-call** | Pager response, alert triage, runbook creation or improvement | Outcome: reliability improvements, reduced MTTR, patterns identified across incidents |
| **Tech health** | Dependency upgrades, debt reduction, build time improvements, test infrastructure | Outcome: what's faster/cheaper/more reliable; use `/utility impact-roi` to quantify |
| **Community contributions** | Guilds, knowledge sharing, internal talks, cross-team tooling, open source | Outcome: who benefited, what capability was built, what repeated work was eliminated |
| **Mentoring and coaching** | Code review quality, pairing sessions, onboarding support | Outcome: who grew, what they can now do that they couldn't before |
| **Cross-team support** | Helping other squads unblock, contributing to shared infrastructure | Outcome: what shipped faster or didn't break because of your involvement |
| **Process improvement** | Improving team workflows, reducing meeting overhead, better decision frameworks | Outcome: what's more efficient, what decisions are higher quality |

When logging these entries, use "Tech Health", "Reliability", "Community", or a specific description as the strategic alignment — not "No direct tie-in". These are recognized categories of impact in the Performance@Spotify framework; leaving the alignment blank undersells the work.

### Framing second-order impact

Much of engineering impact — especially at Senior, Staff, and EM levels — is second-order: work whose value is measured through what it *enables* rather than what it *directly produces*. PR reviews, unblocking, coaching, priority decisions, and process improvements are all second-order work. This kind of impact is easy to undersell because the artifacts are less visible than shipped features or closed tickets.

The challenge: "I reviewed 40 PRs this quarter" is an activity, not an outcome. The skill's quality checks will flag it. But the underlying work was genuinely impactful — the question is how to frame it.

**Reframing pattern: activity → what it enabled → who benefited**

| Activity (don't write this) | Enabled outcome (write this) | Evidence to look for |
|------------------------------|------------------------------|---------------------|
| Reviewed 40 PRs | Reviews caught 3 architectural issues before they reached production; review turnaround under 4 hours kept the team's deploy cadence healthy | GHE: review comments with substantive feedback, turnaround time trends |
| Unblocked 3 teams on shared infrastructure | Teams X, Y, Z shipped their features 2 weeks earlier because the shared dependency was resolved; total downstream impact: N user-facing launches | Slack: threads where you resolved the blocker; Jira: dependent tickets that moved after your fix |
| Led weekly squad syncs and 1:1s | Identified and addressed a performance gap early through 1:1 coaching; the engineer went from needing daily guidance to owning a feature end-to-end within 8 weeks | 1:1 notes (Google Drive); the engineer's PR history showing increasing scope over time |
| Made the priority call to defer feature X for tech health Y | Tech health investment reduced incident rate from 3/month to 0 over the following quarter; feature X was delivered next quarter without the operational risk | Jira: tech health tickets completed; Oliver: incident rate trend; the deferred feature's eventual delivery |
| Onboarded 2 new engineers | Both engineers shipped their first production PRs within 3 weeks (team average was 6 weeks); created an onboarding doc now used by the whole squad | GHE: new engineers' first PRs and merge dates; Google Drive: onboarding doc with usage stats |
| Ran hiring loop for 3 candidates | Hired 1 engineer who filled a critical gap in the team's ML expertise; the new hire led the model migration that was blocked for 2 quarters | Hiring pipeline (manual); the new hire's subsequent impact |

**The key question for any second-order entry:** *"What would not have happened — or would have happened slower, worse, or not at all — without my involvement?"*

This applies at every level, with different weight:
- **Eng I/II:** Second-order work is mostly code reviews and helping teammates. Frame as learning and engagement evidence.
- **Senior:** Second-order work is a differentiator. Frame as enabling others — your reviews, mentoring, and architectural guidance raised the squad's capability.
- **Staff:** Second-order work is the primary impact signal. Frame as cross-squad influence — decisions you shaped, directions you set, capability you built across teams.
- **EM:** Nearly all impact is second-order. Frame as what the team achieved *because of* your priorities, coaching, hiring, culture, and decision-making — not what the team achieved while you happened to be the manager.

**How `prep` uses this:** During Step 2 (deepening), if an entry describes an activity rather than an outcome, the agent should probe with: "What would not have happened without your involvement?" and "Who benefited, and can you name the specific effect?" rather than immediately flagging it as an activity-trap violation. The activity may represent genuine second-order impact that needs reframing, not removal.

### The Impact Session

The Impact Session (also called the Expectations Sync) follows a 3-step structure:

1. **Reconnect on priorities and context** (5 min) — What has shifted since we last synced? Are current priorities still right?
2. **The three big questions** (20-25 min) — What impact are we here to drive? How has your impact landed? What would make your impact matter more?
3. **Shared commitments** (5 min) — Expected outcomes, key work to own, growth plan, what you need from each other

The `prep` subcommand maps to Section 2's questions. `add --from groove-sync` populates context for Section 1. See [`idt-level-templates.md`](idt-level-templates.md) for level-specific versions of all three sections.

---

## The 3 Workday Employee Questions

### Question 1 — What impact did I drive, and how did the way I showed up shape it?

- Name 2-3 outcomes that mattered, grounded in agreed expectations
- Focus on what changed because of your work
- Reflect on unique strength: distinctive judgment, insight, smart risk, or creative thinking
- Consider how the way you showed up (values in action) shaped those outcomes

### Question 2 — Where did impact or how I showed up fall short, and what did I learn?

- Honest self-awareness matters more than a polished answer
- Reflect on both what you delivered and how you showed up

### Question 3 — What actions can I take to grow and raise impact next?

- One or two concrete actions — a skill to build, a behaviour to shift, a barrier to address
- Frame around the impact that growth would unlock, not the development itself

**Constraints:** Text only, no links or attachments. 500 characters per question.

---

## Quality Checks

These checks are applied by `prep` against its drafted output before presenting to the user.

1. **Outcomes vs activities** — most important check. Red flags: "I worked on", "I was responsible for", "I supported" with no stated outcome.
2. **Unique strength / edge** — distinctive judgment, risk, or perspective that no one else (or any AI tool) would have reached the same way.
3. **Expectations grounding** — does the answer connect to agreed expectations from Expectations Syncs?
4. **Credibility probe** — at least one concrete example per significant claim. Do not include claims without evidence.
5. **WHAT vs HOW** (Q1 only) — outcomes covered AND values behaviors present.
6. **Thin input** — if a response lacks specific outcomes/learnings/examples, surface the gap before drafting.
7. **"Nothing went wrong" probe** (Q2) — if the employee says nothing fell short, probe for deprioritised or stalled work, not just failures.
8. **Character limit** — 500 chars per question. Target 450-500. Show count as `[423 / 500 characters]`. Trim priority: keep impact claims, trim adjectives/transitions.
9. **Language patterns** — flag minimising ("just", "only"), effort trap ("it was really hard"), comparison trap (mentioning peers), overclaiming.

---

## Workday-Ready Output Format

After all three answers are finalized, output as a single copy-paste block:

```
What impact did I create?
[final answer text only]

Where did I fall short, and what did I learn?
[final answer text only]

What would it take to create more impact next?
[final answer text only]
```

No character counts, labels, or annotations inside the block. Add one line after:
"These are a starting point — make sure each one sounds like you before you submit."

---

## Cycle Awareness

### July cycle (mid-year) — current

- **I&DT only:** self-reflection + conversation + Workday documentation
- **No Impact Snapshot** — no formal assessment on the Impact Scale
- **No compensation review**
- Focus: reflection, feedback, growth planning
- Timeline: Workday kick-off May 27, self-reflection open May 26, schedule talks June 8 – July 3, cycle closes July 3, 2026
- Submit in Workday at least 48 hours before your talk
- Schedule directly with your manager

### January cycle (year-end)

- I&DT (same self-reflection process as July)
- **Impact Snapshot** — managers formally assess bandmates on the Impact Scale (WHAT x HOW). First Impact Snapshot will be January 2027.
- **Compensation review** tied to Impact Snapshot outcomes
- **Calibration** across ETeam/ETeam-1 organizations

### How `prep` adapts by cycle

- **July:** Focus purely on self-reflection quality. No Impact Scale positioning needed — the July cycle is about reflection, feedback, and growth.
- **January (future):** `prep --calibrate` will additionally surface how entries map to Impact Scale levels, helping you understand where your self-reflection positions you before your manager runs the Impact Snapshot.

> **Note:** These dates change each cycle. Verify against the [Performance@Spotify playbook](https://docs.google.com/presentation/d/1i0p_sQRPPq1SrHqXrs0Wfs3BAbH2tK8K8GyQ7c5fKB4/) or the [Workday & Claude companion guide](https://docs.google.com/presentation/d/1j1_54HSyzX-bX8oCNSeMLmVr8GgdEVfcqdDHXrbsXBU/).

---

## How `prep` Uses This Reference

The `prep` subcommand reads this file at inference time to:

1. Map impact-log entries to the three Workday questions via a 7-step interactive coaching flow (see [`prep-interactive-flow.md`](prep-interactive-flow.md))
2. Apply the quality checks against its drafted output
3. Produce a Workday-ready copy-paste block within 500-char limits
4. Warn the user if this file's access date is more than 6 months old

## Discovery Mode — MCP Sources for Evidence

During the interactive `prep` flow (Step 2), the agent offers to search MCP sources for quantitative evidence the user can incorporate into their self-reflection. Sources are selected based on the entry's context:

| Entry context | MCP sources | Evidence surfaced |
|---|---|---|
| PR source link | GHE MCP | Code change scope, cross-repo impact, reviewer count |
| Jira ticket link | Groove MCP | DOD -> initiative -> bet alignment chain |
| Experiment reference | Oliver MCP | Metric deltas, exposure count, ship decision |
| Reliability / SLO work | Oliver MCP | SLO compliance, error budget, dependency fan-out |
| Data / pipeline work | Lineage MCP | Consumer reach (accesses, users, teams over 30d) |
| Any entry | Slack MCP | Feedback, recognition, cross-team coordination |

Discovery is optional at each step — the user can always answer from memory. Evidence is presented as 2-4 bullet summaries with source links, not data dumps. See [`prep-interactive-flow.md`](prep-interactive-flow.md) for the full discovery mode specification.
