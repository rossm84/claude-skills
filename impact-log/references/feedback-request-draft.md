# `feedback-request draft` — Guided Peer Feedback Writing

Coach yourself through writing peer feedback by reflecting on what you observed. The tool asks questions; you write the answers. It produces a local draft you review before pasting into a feedback form.

## When to use

- "Help me write feedback for [name]"
- "I need to give peer feedback but don't know where to start"
- "Draft feedback for my peer review"
- "Coach me through writing feedback"

## What this does and does not do

**Does:**
- Walks you through reflective questions about your peer's work
- Prompts for concrete examples and observed outcomes
- Helps you frame feedback constructively
- Produces a local draft organized by dimension

**Does not:**
- Write feedback for you — it prompts, you provide the substance
- Evaluate your peer — it helps you articulate your own observations
- Access your peer's data — no pulling their PRs, Jira tickets, Slack messages, or any other source. What you observed firsthand is the only input.
- Submit anything — draft-only, always. You paste the final version into the form yourself.
- Track what feedback was drafted, for whom, or whether it was submitted

## Guided workflow

### Step 1: Who and what cycle

Ask:
- "Who are you writing feedback for?" (name only — no data lookup)
- "Which cycle?" (e.g., H1 2026, mid-year)
- "What's your relationship?" (peer, cross-team collaborator, manager, report)

### Step 2: Reflective prompts by dimension

Walk through four dimensions, one at a time. For each, ask 2-3 reflective questions. The user answers in their own words.

**Dimension 1: Growth and initiative**
- "What challenges did [name] take on during this period that stood out to you?"
- "Did you observe them seeking feedback or learning from setbacks? What happened?"
- "How did they approach areas where they were less experienced?"

**Dimension 2: Technical contribution and delivery**
- "What was the most significant thing [name] delivered or contributed to technically?"
- "How would you describe the quality of their work? Can you give a specific example?"
- "Did they handle any incidents, complex debugging, or architectural decisions you observed?"

**Dimension 3: Collaboration and team impact**
- "How did working with [name] affect your work or the team's outcomes?"
- "Did they share knowledge, help others, or contribute to the team beyond their own tasks?"
- "How did they handle disagreements or difficult conversations?"

**Dimension 4: Leadership and broader impact**
- "Did [name] drive any changes beyond their immediate responsibilities?"
- "How did they balance competing priorities — business needs, technical quality, team needs?"
- "Did they mentor, interview, or contribute to the broader community?"

For each answer, follow up once with: "Can you give a concrete example of that?" if the answer is abstract.

### Step 3: Summary reflections

- "What is one specific thing [name] does well that you value most?"
- "What is one area where you think [name] could grow?"

### Step 4: Draft assembly

Assemble the user's answers into a structured draft:

```
Peer Feedback for [Name] — [Cycle]

Growth & Initiative
[User's answers from dimension 1, lightly organized into flowing text]

Technical Contribution & Delivery
[User's answers from dimension 2]

Collaboration & Team Impact
[User's answers from dimension 3]

Leadership & Broader Impact
[User's answers from dimension 4]

Summary
Strength: [User's answer]
Growth area: [User's answer]
```

Present the draft and ask: "Would you like to revise anything before copying this into your feedback form?"

## Adaptation to form structure

If the user has already set up a `feedback-request` flow with a specific form template, the draft dimensions can be reordered or relabeled to match the form's sections. The four default dimensions are general enough to map to most peer feedback forms:

| Default dimension | Maps to IC/CAB form section | Maps to generic form |
|-------------------|-----------------------------|---------------------|
| Growth & Initiative | Competence and Growth Mindset | Growth / Learning |
| Technical Contribution | Technical Proficiency and Achievement | Delivery / Quality |
| Collaboration & Team Impact | Collaboration and Values | Teamwork / Communication |
| Leadership & Broader Impact | Leadership and Accountability | Leadership / Initiative |

## Writing guidelines

When assembling the draft from the user's answers:

- **Include all examples** the user provided — never omit provided evidence
- **Never add facts** the user didn't state — no hallucinated meetings, conversations, or outcomes
- **Inferences about impact are acceptable** if they follow from what the user said (e.g., "This kind of initiative builds trust across teams")
- **Frame growth areas constructively** — what could the person gain by improving, not what they're doing wrong
- **Maintain the user's voice** — the draft should sound like the user wrote it, not like a template

## Composition

| Skill | How they connect |
|-------|-----------------|
| [`feedback-request`](feedback-request.md) | `draft` coaches the writing; `feedback-request` handles collection (form setup, reminders, submission tracking). Run `draft` first, then paste into the form that `feedback-request` manages. |
| [`prep`](prep-interactive-flow.md) | `prep` coaches self-reflection about your own work; `draft` coaches reflection about a peer's work. Same coaching pattern, different direction. |
| [`gather`](gather.md) | `gather` surfaces your own contributions from MCP sources; `draft` explicitly does NOT gather the peer's contributions — only what you observed firsthand. |

## Privacy

- All drafting is local — nothing leaves the user's machine until they manually paste into a form
- The tool never accesses the peer's data (GHE PRs, Jira tickets, Slack messages, Google Docs)
- The tool never sees other people's feedback about the same peer
- No tracking of what feedback was drafted, for whom, or whether it was submitted
- The user controls what goes into the form — the draft is a starting point, not a submission

## Prior art

- `write-feedback` skill (Premium Desirability team, across 5+ repos at `premium-desirability-pi/`) — transforms rough feedback notes into polished peer feedback prose. Direct precedent for AI-assisted feedback writing. Key difference: `write-feedback` takes existing notes as input and polishes them; `draft` starts from scratch with reflective prompts.
- IC/CAB/Steps Hybrid peer feedback form — multi-framework form with 4 grid dimensions (Growth Mindset, Technical Proficiency, Collaboration/Values, Leadership/Accountability). Referenced as form template design prior art for the default dimension structure.
