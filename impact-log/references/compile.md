# `compile` — Biannual Long-Form Synthesis

Biannual long-form synthesis for I&DT conversation prep. Reads monthly syntheses directly, clusters by pillar, and drafts a 3-4 page document covering the full cycle. Complements the short-form `prep` subcommand (Workday submission).

## When to use

Run before an Impact & Development Talk to produce the full narrative document for the conversation. The document is longer and richer than the Workday submission — it's the story you tell in the meeting, not the summary you paste into the form.

A user preparing for an I&DT would run `compile` first (full narrative for the conversation), then `prep` (distill into 500-char Workday answers).

## Architectural Constraint

`compile` is a **transform-only** subcommand. It reads monthly synthesis files (`~/.impact-log/contributions/YYYY-MM-synthesis.md`) — it does not query external systems. If the monthly syntheses are thin, the compile output is thin. Weekly gathering is load-bearing for the entire chain.

## Workflow

1. **Read monthly syntheses.** Load all synthesis files for the current cycle (typically 6 months for a biannual I&DT).

2. **Cluster by pillar.** Group contributions across months into the three pillars (Business Impact, Technical Excellence, Culture & Organization). For EMs, the third pillar is Team/Culture/Organization or Enabling Others depending on the level template.

3. **Draft Looking Back / Right Now / Looking Ahead.**

   **Looking Back** (1-2 pages): What impact was delivered this cycle, organized by pillar. Each pillar section draws from the monthly syntheses' project narratives, maintaining the DELIVERY/INFLUENCE classification and strategic alignment context. Highlight the 2-3 most significant outcomes with concrete evidence.

   **Right Now** (0.5-1 page): Current state — what's in progress, what's at risk, what's going well. Draws from the most recent monthly synthesis and any in-progress entries in the impact log.

   **Looking Ahead** (0.5-1 page): Growth actions and priorities for the next cycle. Informed by gaps surfaced in monthly syntheses and the user's own reflection.

4. **Generate Workday Summary.** Draft three 500-character answers for the Workday I&DT submission form, mapped from the compile output:
   - Q1 (What impact did I drive?) ← Looking Back, Business Impact + Technical Excellence pillars
   - Q2 (Where did I fall short?) ← Growth edges from Looking Back + Right Now
   - Q3 (What actions to grow?) ← Looking Ahead + growth edges

   Character counting uses `wc -m` (characters, not bytes).

5. **Apply level-specific framing.** When a career level is configured, use the level template's dimensions and reflection questions to frame the narrative (see [`idt-level-templates.md`](idt-level-templates.md)). For example:
   - Senior Eng: "Enabling Others" pillar draws from mentoring, code review impact, and knowledge sharing contributions
   - EM: pillars reframe as Business Impact, Technical Excellence, and Team/Culture/Organization per the EM template
   - Senior EM / Director: organizational-level framing per the derived templates

6. **Apply squad rubric.** When a squad rubric is configured, enrich the narrative with team-specific outcome definitions, HOW behaviors, and Impact Scale examples.

7. **Cycle awareness.** Adapt output for July vs January cycle:
   - **July cycle:** Focus on reflection + growth. No Impact Snapshot context needed.
   - **January cycle:** Include Impact Snapshot positioning context — where the compile output maps to the Impact Scale levels (as framing context, not as a self-rating). The skill estimates work value, not performance; see the impact estimation design decisions case study in `docs/case-studies/` for the full boundary rationale.

## Private vs Exported Content

Following the pattern from Sarah's dev-talk-report, the full compile output includes sections that are for the user's eyes only:

| Section | In full output | In Google Docs export (`persist --to gdoc`) |
|---------|:-:|:-:|
| Looking Back | Yes | Yes |
| Right Now | Yes | Yes |
| Looking Ahead | Yes | Yes |
| Workday Summary (3 questions) | Yes | Yes |
| Conversation Prep (anticipated questions + prepared answers) | Yes | **No** |
| Evidence Appendix (source links, project arcs, recognition quotes) | Yes | **No** |

The user controls what gets shared. `persist --to gdoc` exports only the manager-facing sections. The private sections stay in the local compile output.

## Output Format

The compile output is written to `~/.impact-log/compile/YYYY-HN-compile.md` (e.g., `2026-H1-compile.md`):

```markdown
# Impact & Development Talk — YYYY H1/H2

**Generated:** YYYY-MM-DD
**Career level:** [level]
**Squad rubric:** [name or "none"]
**Cycle:** July (mid-year) / January (year-end)

---

## Workday Summary

Three 500-character answers per the Workday I&DT questions defined in [`idt-framework-employee.md`](idt-framework-employee.md) § The 3 Workday Employee Questions. Each answer shows its character count.

### Q1 — Impact and values
[500-char answer] [423 / 500 characters]

### Q2 — Shortfalls and learnings
[500-char answer] [487 / 500 characters]

### Q3 — Growth actions
[500-char answer] [456 / 500 characters]

---

## Looking Back

### Business Impact
[Narrative with 2-3 key outcomes, strategic alignment, evidence links]

### Technical Excellence
[Narrative with system improvements, quality contributions, reliability impact]

### Culture & Organization / Enabling Others
[Narrative with mentoring, coaching, community, team-building contributions]

---

## Right Now

[Current state: what's in progress, what's at risk, what's going well]

---

## Looking Ahead

[Growth actions, priorities for next cycle, skills to build]

---

## Conversation Prep (private — not exported)

### Anticipated questions
- [Question the manager might ask, with a prepared response]
- [Question about a gap or shortfall, with honest framing]

### Evidence Appendix
- [Source links organized by project]
- [Recognition quotes from Slack (summarized, not quoted verbatim)]
- [Project arcs: timeline from start to outcome]
```

## Relationship to Other Subcommands

```
gather (weekly) → synthesize (monthly) → compile (biannual) → prep (Workday)
```

- `gather` is the only subcommand that queries external systems
- `synthesize` groups weekly blocks into monthly narratives
- `compile` clusters monthly narratives into a full-cycle document
- `prep` distills the cycle into 500-char Workday answers

`compile` and `prep` serve different audiences:
- `compile` is for the I&DT **conversation** (the full story, 3-4 pages, with private prep material)
- `prep` is for the Workday **submission** (3 answers, 500 chars each, copy-paste ready)

A user can run `prep` without `compile` (if they prefer the interactive coached flow over the long-form document). A user can run `compile` without `prep` (if they want the document but will write the Workday answers manually). The two compose naturally but neither requires the other.
