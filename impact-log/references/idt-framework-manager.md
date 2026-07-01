# I&DT Framework -- Manager Analysis & Documentation

> **Freshness notice**
> - **Accessed:** 2026-06-08
> - **Sources:**
>   - `impact-dev-talk-manager` claude.ai Skill (downloaded from claude.ai/customize/skills)
>   - [Performance@Spotify playbook](https://docs.google.com/presentation/d/1i0p_sQRPPq1SrHqXrs0Wfs3BAbH2tK8K8GyQ7c5fKB4/) (canonical source)
>   - [Workday & Claude companion guide](https://docs.google.com/presentation/d/1j1_54HSyzX-bX8oCNSeMLmVr8GgdEVfcqdDHXrbsXBU/)
>   - [Impact Info Session — PZN](https://docs.google.com/presentation/d/1ZLCUp3iX_wxjtGWE6-57wliKzxq0DghuUdaNHoMOVkg/) (June 2026)
> - This content was captured on the date above and may not reflect the current I&DT cycle. Check the canonical sources or re-download the claude.ai Skill for updates.

---

## Performance Framework

**Impact** is the value work creates for the team, organisation, and Spotify. Three dimensions:

- **Outcome-focused** -- what changed or improved as a result; not just activity
- **Adding value** -- creates real, observable value for users, creators, customers, or Spotify teams
- **Matters to Spotify** -- advances Spotify's strategies or org priorities

### Performance = WHAT x HOW

Both count equally. Impact delivered without the right behaviours does not count.

**WHAT** = the outcomes and results delivered

**HOW** = how the work was done, through Spotify's three values:

| Value | What it looks like |
|-------|-------------------|
| **One Team** | Synchronise broadly, communicate openly, think in systems |
| **Human Judgement** | Make informed decisions, adapt with awareness, share knowledge generously |
| **Make It Happen** | Own the outcome, improve through debate, execute with precision |

**Agreed expectations** are set through Expectations Syncs -- quarterly conversations where manager and bandmate align on what impact looks like. The I&DT is anchored in those expectations. Managers are accountable for setting a clear direction for impact.

---

## The 3 Workday Manager Questions

These three questions are completed in **one free-text field** in Workday. The total limit is **500 characters across all three questions combined**.

### Question 1 -- Impact and values / edge

What impact and values did you recognise, and where did the bandmate bring their unique edge?

**Edge** = distinctive capability, judgment, insight, smart risk, or creative thinking that shaped the outcome in a way no one else (or any tool) could have.

### Question 2 -- Actionable feedback and differing perspectives

What actionable feedback did you share, and where did perspectives differ?

Name the specific behavior, the impact it had, what doing it better looks like, and any gaps in how you each saw it.

### Question 3 -- Agreed actions and manager commitments

What concrete actions did you agree on to grow and to raise impact next -- including what you as the manager committed to?

Goes both ways.

---

## Self-Reflection Analysis Framework (Phase 1 -- Pre-conversation)

This is the analytical lens the manager skill applies when reading a bandmate's self-reflection. The `--calibrate` flag applies this same lens to the IC's own draft.

1. **Alignment check** -- where the reflection aligns with agreed expectations. Where it diverges (absent, overstated, or framed differently).

2. **Bright spots vs outliers** -- are highlighted wins representative of consistent performance, or standout moments in a more uneven pattern? Do not affirm wins without asking this.

3. **Gap signals** -- where they acknowledge falling short or express uncertainty.

4. **Edge presence** -- does the reflection name distinctive judgment, insight, or risk-taking beyond standard execution?

5. **HOW check** -- does the reflection show values behaviours: proactive context-sharing, constructive challenge, transparency of reasoning, cross-boundary thinking?

6. **Excelled vs next actions** -- where has this person clearly delivered or exceeded? What 1-2 areas would most elevate impact going forward?

---

## Bias Checks

These checks are run before finalising documentation. The `--calibrate` flag applies them to the IC's own self-reflection as self-assessment traps. When a career level is configured (via `--level` or `career_level` in config.json), bias checks use level-appropriate framing — e.g., "HOW missing" checks for engagement and learning evidence at Eng I vs enabling-others and mentoring evidence at Senior. See [`idt-level-templates.md`](idt-level-templates.md) for per-level dimension definitions.

### 1. Comfort trap

Generic or vague strengths with no specifics ("great collaborator", "reliable") and no supporting evidence.

### 2. Deficit-only trap

Evidence is mostly growth areas with little recognition. Lead with recognition before gaps.

### 3. Activity trap

Evidence describes activities, not outcomes ("they led the project", "they were responsible for X"). Look for results and impact instead.

### 4. HOW missing

Outcomes are covered but nothing addresses behaviors or Spotify values.

### 5. Monologue trap

Next steps are all self-assigned; no indication of genuine dialogue or joint ownership.

### 6. Debate trap

Reads like a verdict being defended rather than an outcome of shared discovery.

### 7. Vague next steps

General goals without specifics on what, by when, and how success is defined.

### EM-specific anti-patterns (when `--level em/sem/director` is configured)

These additional checks apply when the user is an EM reflecting on their own leadership impact. They supplement the generic bias checks above.

#### 8. Team-outcome-without-attribution trap

The reflection describes what the team delivered without naming the EM's specific enabling contribution. "My team shipped feature X" is an activity from the EM's perspective — the outcome is what the EM did that made the team capable of shipping it (coaching, priority setting, unblocking, hiring, organizational design).

Probe: "What specifically did you do — what decision, coaching conversation, or structural change — that enabled this team outcome?"

#### 9. Execution-depth trap

The EM describes hands-on execution (reviewing PRs, writing code, debugging incidents) as their primary impact. While EMs may contribute technically, their primary value is through leverage — developing people, setting direction, building culture. Execution-heavy self-reflections may indicate the EM is operating at the IC level rather than the EM level.

Probe: "This sounds like strong IC work. How did your involvement develop your engineers' capability to handle this without you next time?"

#### 10. Invisible-coaching trap

The EM's most impactful coaching work (1:1 conversations, career guidance, conflict resolution) leaves no artifact that the pull modes can surface. If the reflection is thin on people-development evidence, it may be because the evidence lives in the EM's head, not in any searchable system.

Probe: "You mentioned coaching [person]. Is there a 1:1 doc, Slack thread, or Jira ticket that captures the before/after — what they could do before your involvement vs. after?"

---

## Language Pattern Checks

- **Personality over performance** -- words like "enthusiastic" or "friendly" without outcome evidence
- **Effort over outcomes** -- "worked really hard" without stating the result
- **Comparison to peers** -- remove; the write-up should stand on this person alone

---

## How `prep --calibrate` Uses This Reference

The `--calibrate` flag reads this file at inference time, after the interactive `prep` flow completes (see [`prep-interactive-flow.md`](prep-interactive-flow.md)):

1. Run the Self-Reflection Analysis Framework against the IC's own `prep` output
2. Apply the Bias Checks as self-assessment traps (reframed from manager perspective to IC perspective)
3. Surface any flags as questions for the IC to consider before submitting
4. Specifically check:
   - "Are your highlighted wins representative or outlier peaks?"
   - "Did you fall into the activity trap, comfort trap, or HOW-missing pattern?"
   - "Does your self-reflection address all your agreed expectations?"
   - "Did you name your unique edge/strength?"

---

## Values in Action — Leader Behaviors

The Playbook distinguishes leader behaviors from bandmate behaviors. This is relevant for `prep --calibrate` when used by EMs or when the manager is reflecting on their own HOW.

| Value | Bandmate behaviors | Leader behaviors |
|-------|-------------------|-----------------|
| **One Team** | Synchronise broadly, communicate openly, think in systems | Create alignment, remove silos, model cross-boundary collaboration |
| **Human Judgement** | Make informed decisions, adapt with awareness, share knowledge generously | Create space for dissent, balance data with intuition, develop judgment in others |
| **Make It Happen** | Own the outcome, improve through debate, execute with precision | Set clear direction, hold the bar on quality, enable autonomy while maintaining accountability |

---

## Impact Snapshot & Impact Scale (January cycle only)

The **Impact Scale** is a 5-level rubric (Low → Exceptional) that defines what different levels of impact look like. It applies to everyone — understanding where your work falls on this scale helps frame self-reflection at any level. See [`idt-framework-employee.md`](idt-framework-employee.md) § Impact Scale for the IC-facing explanation.

The **Impact Snapshot** is the manager-side assessment process that uses the Impact Scale. Starting January 2027, managers formally rate each bandmate on the scale using the WHAT × HOW formula. The Snapshot is NOT part of the July cycle — it only happens in January, alongside compensation review and calibration.

The Impact Snapshot uses the WHAT × HOW formula:
- **WHAT** = outcomes and results delivered (assessed against agreed expectations)
- **HOW** = behaviors through Spotify's three values

| Level | Description | Expected distribution |
|-------|-------------|----------------------|
| **Low** | Below the bar; work or behaviors fall short | ~5% |
| **Inconsistent** | Sometimes meets, sometimes not (may be recently hired/promoted) | ~15% |
| **Consistent** | Reliably meets the bar; delivers meaningful outcomes | ~40% |
| **High** | Consistently exceeds the bar; sustained high-quality outcomes | ~30% |
| **Exceptional** | Consistently exceptional, well above the bar | ~10% |

Distribution targets sit at the ETeam/ETeam-1 level and are "a tool, not a quota." Calibration happens across organizations to ensure consistency.

See the [Performance@Spotify playbook](https://docs.google.com/presentation/d/1i0p_sQRPPq1SrHqXrs0Wfs3BAbH2tK8K8GyQ7c5fKB4/) (slides 41-44) for the full Impact Snapshot definition and calibration process, and slides 48-58 for the detailed Impact Scale with per-level WHAT and HOW indicators.

The `--calibrate` flag will be extended to surface Impact Scale positioning in the January cycle (future enhancement).

---

## Cycle Awareness

### July cycle (mid-year) — current

- **I&DT only:** self-reflection + conversation + Workday documentation
- **No Impact Snapshot** — no formal assessment on the Impact Scale
- **No compensation review**
- Focus: reflection, feedback, growth planning
- Manager documents within 48 hours after conversation
- Timeline: schedule talks June 8 – July 3, 2026

### January cycle (year-end)

- I&DT (same process as July)
- **Impact Snapshot** — managers formally assess bandmates on the Impact Scale
- **Compensation review** tied to Impact Snapshot outcomes
- **Calibration** across ETeam/ETeam-1 organizations

> **Note:** These dates change each cycle. Verify against the [Performance@Spotify playbook](https://docs.google.com/presentation/d/1i0p_sQRPPq1SrHqXrs0Wfs3BAbH2tK8K8GyQ7c5fKB4/).
