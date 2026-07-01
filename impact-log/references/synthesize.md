# `synthesize` — Monthly Narrative Synthesis

Monthly synthesis rewrites weekly `gather` blocks into a grouped narrative impact summary. `synthesize` only reshapes data that `gather` already collected — it never makes MCP calls.

## When to use

Run at the end of each month (or when preparing for a mid-cycle check-in). Reads all weekly blocks from the current month's contributions file and produces a narrative summary.

## Architectural Constraint

`synthesize` is a **transform-only** subcommand. It reads the monthly contributions file (`~/.impact-log/contributions/YYYY-MM.md`) and produces a synthesis — it does not query external systems. If the weekly blocks are thin, the synthesis is thin. Weekly gathering is load-bearing for the entire chain.

## Workflow

1. **Read the monthly file.** Load all weekly blocks from the contributions file for the specified month.

2. **Group by epic/project.** Propose epic-based groupings: PRs, tickets, and docs that relate to the same initiative are clustered together. Present the groupings to the user for correction — cross-cutting work spanning multiple epics may need manual grouping.

3. **Classify as DELIVERY or INFLUENCE.** For each grouped contribution:
   - **DELIVERY:** Direct output — code shipped, features launched, experiments concluded, bugs fixed, pipelines built
   - **INFLUENCE:** Enabling work — code reviews, mentoring, unblocking, architectural guidance, process improvements, cross-team coordination

   The balance between DELIVERY and INFLUENCE is level-aware (see Level-Aware Narrative Framing below).

4. **Enrich with business context.** For each group, pull strategic alignment from the weekly blocks' Business Context sections (already gathered in Step 6 of `gather`). Frame each group's impact in terms of the DOD, initiative, or bet it contributed to.

5. **Draft the narrative.** For each grouped contribution, produce:

   | Field | Content |
   |-------|---------|
   | **Project/Epic** | Name and Groove/Jira link |
   | **Classification** | DELIVERY or INFLUENCE |
   | **What happened** | Outcome-focused summary (not activity list) |
   | **Strategic alignment** | DOD/initiative/bet connection |
   | **Multiplier effect** | If applicable: who benefited beyond the direct output |
   | **Sustained ownership** | If applicable: ongoing commitment vs one-time contribution |

6. **Surface pillar coverage.** Show which pillars (Business Impact, Technical Excellence, Culture & Organization) are represented and which have gaps.

7. **User reviews and edits.** The user reviews the synthesis, corrects groupings, adjusts framing, and adds context the data missed.

## Level-Aware Narrative Framing

When a career level is configured, `synthesize` adjusts the DELIVERY/INFLUENCE balance and framing:

| Level | Expected balance | Framing emphasis |
|-------|-----------------|-----------------|
| **Eng I/II** | Nearly all DELIVERY | Learning, quality growth, engagement. INFLUENCE is notable but not expected. |
| **Senior** | Mix — DELIVERY on hard problems + emerging INFLUENCE | Enabling others is a differentiator. Frame both. |
| **Staff** | Significant INFLUENCE expected | Cross-squad impact, architectural guidance, community building. |
| **EM** | Nearly all INFLUENCE | People development, priority decisions, culture building, organizational design. |
| **Senior EM / Director** | All INFLUENCE | Multi-squad/org-level impact through leaders and strategy. |

An Eng II who can articulate multiplier effect ("my runbook saved 4 hours per incident for future responders") is making a stronger case than one who only lists deliveries — the concepts apply at every level, with different weight.

## Squad Rubric Integration

When a squad rubric is configured (see SKILL.md § Squad Rubric Discovery), `synthesize` reads it and enriches the narrative with team-specific outcome definitions and HOW behaviors. The squad rubric provides context for what "Business Impact" or "Technical Excellence" means in this specific team's domain.

## Output Format

The synthesis is written to `~/.impact-log/contributions/YYYY-MM-synthesis.md`:

```markdown
# YYYY-MM Impact Synthesis

**Generated:** YYYY-MM-DD
**Career level:** [level or "not configured"]
**Squad rubric:** [name or "none"]

## Project: [Epic/Initiative Name]

**Classification:** DELIVERY
**Strategic alignment:** [DOD/initiative link]

[Outcome-focused narrative — what changed, who benefited, what it enables]

**Multiplier effect:** [if applicable]
**Sustained ownership:** [if applicable]

## Project: [Next Epic/Initiative]

...

## Pillar Coverage

| Pillar | Coverage | Notes |
|--------|----------|-------|
| Business Impact | Strong | 3 projects aligned to DODs |
| Technical Excellence | Moderate | System improvements but no reliability metrics |
| Culture & Organization | Gap | No mentoring or community contributions captured |
```

## Relationship to `prep`

`synthesize` produces a monthly narrative. `prep` produces Workday-ready answers. They serve different purposes:

- `synthesize` is for the IC/EM's own reference and for the I&DT conversation (the full story)
- `prep` distills the log into 500-char Workday answers (the submission)

A user preparing for an I&DT would typically review their monthly syntheses for context, then run `prep` to produce the Workday submission.
