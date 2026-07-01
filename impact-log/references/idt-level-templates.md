# I&DT Level-Specific Prep Templates

> **Freshness notice**
> - **Accessed:** 2026-06-11
> - **Sources:** Level-specific I&DT prep templates published by Personalization engineering leadership
>   - [Eng I template](https://docs.google.com/document/d/1Mo1liBAXeyeS-5eo-olnwH1lV4pjY1JRDj4ZN39iQkE/)
>   - [Eng II template](https://docs.google.com/document/d/1Du-GJ-uW468bHZjn3Wk7zL_UhefSkfpc_AQgLl4iqxA/)
>   - [Senior Eng template](https://docs.google.com/document/d/1X-Gboti_aceCoBOrdXt3qs502NpyFgQlPu_KKYlz8c8/)
>   - [Staff Eng template](https://docs.google.com/document/d/11HTPFEOWmN7kZEiN_Xbt_nz3D4euJnY84vUu5VxmU9U/)
>   - [EM template](https://docs.google.com/document/d/1SMAdq4E5xCIyPNQbNXQEhlffjTLq7SlogpyRIqq6TLY/)
>   - [Senior EM template](https://docs.google.com/document/d/16yUETQ_qKTbytdKM0Y539T7XHUFwRtilkTZegpok_ts/)
>   - [Impact Info Session — PZN](https://docs.google.com/presentation/d/1ZLCUp3iX_wxjtGWE6-57wliKzxq0DghuUdaNHoMOVkg/) (June 2026)
> - These templates are optional. Users can use them, use the generic Performance@Spotify framework, or provide their own template.
> - This content was captured on the date above. Check the source documents for updates.

---

## How `prep --level` uses this reference

When the user configures a career level (via `--level` flag or `career_level` in config.json), Step 2 of the interactive prep flow uses the level-specific dimensions and reflection questions below instead of the generic three impact dimensions from [`idt-framework-employee.md`](idt-framework-employee.md).

If no level is configured, `prep` falls back to the generic framework (no regression).

---

## Shared framing (all levels)

Impact is meaningful change, not volume. Human judgment on the "what" and "why" is the scarcest resource. AI takes on more of the implementation; what only you can do is pick the right problems, frame them clearly, and make the calls that move things forward.

### About "Suggested evidence signals" per level

Each level below includes a "Suggested evidence signals" table. These are **discovery hints for `prep` — not evaluation criteria or a scoring rubric.** The tables tell the agent where to look in MCP sources for quantitative data that *might* strengthen the user's self-reflection. They do not define what good looks like, what the numbers should be, or how to map data to Impact Scale levels.

The user always decides what's relevant to their story. The agent surfaces data; the user interprets it. A signal that appears at one level but not another reflects where that data is *typically most useful for self-reflection*, not where it *counts more for evaluation*.

The team impact statement (configured separately) provides mission-specific context.

---

## Eng I

### Role definition

Learning about your squad and how to effectively contribute to it. Building the understanding — of the codebase, the systems, the mission, the team — that will let you contribute with increasing independence over time.

At this step, impact means showing up consistently, engaging actively, asking good questions, completing work with real care, and learning visibly.

### Three dimensions

**1. Business Impact**
Building your understanding of your squad's mission and how your work connects to it. Not expected to drive direction — but expected to be curious about it. When you understand why a piece of work matters, you make better decisions about how to approach it.

**2. Technical Excellence**
Delivering working, tested code — with support where needed. Taking the quality of your work seriously: correctness, tests, asking for review and feedback. Actively learning the codebase, systems, and engineering practices. Engaging genuinely with code review.

**3. Contributing to the Team**
A positive, engaged presence in the squad. Participating actively in rituals and discussions — asking questions and sharing perspective. Honest about what you don't know, proactive about seeking help. Engaging well with feedback and acting on it.

### Reflection questions

**How has your impact landed?**
- Did you understand why the work you delivered mattered — to the squad, to the mission, to Spotify?
- Were there moments where that understanding shaped how you approached something or helped you make a better decision?
- Where did you fall short, and what's the most important thing you've learned from it?
- Is the work you've produced good quality — correct, tested, and well-communicated?
- Are you leaving things better than you found them, even in small ways?
- Are you growing in your ability to understand and navigate the codebase with less help than before?
- Are you showing up actively in squad rituals and discussions — asking questions, sharing your perspective?
- Are you acting on the feedback you receive — and can you point to a specific example of growth?

**What would help you grow faster?**
- What's the most important thing you want to get better at over the next six months?
- Where do you feel most uncertain or least confident — and what would help?
- Are there habits you're trying to build (around quality, communication, learning) where you'd benefit from more structure or support?

### Suggested evidence signals

These map the reflection questions above to quantitative data that `prep` discovery mode can surface from MCP sources. Not all signals apply to every entry — the agent selects based on the entry's context.

| Reflection area | Signal | MCP source | What to look for |
|----------------|--------|------------|-----------------|
| Work quality | PR merge rate, review turnaround | GHE | PRs merged vs closed without merge; time from open to first review |
| Work quality | Test coverage on your PRs | GHE | Files changed vs test files changed ratio |
| Learning growth | Code review received | GHE | Feedback themes from reviewers on your PRs over time |
| Team engagement | Slack participation | Slack | Questions asked, threads participated in, help offered |
| Feedback acted on | Commit patterns | GHE | Changes in code patterns after review feedback (qualitative) |

### Looking ahead → Eng II

Making significant contributions without heavy guidance. Start thinking about where you can take slightly more initiative, where you can ask slightly fewer questions before trying, and where you can show that you understand not just how to do the work, but why it matters.

---

## Eng II

### Role definition

Making significant contributions to your squad's work. Delivering meaningful work without heavy guidance, taking clear ownership of what you build, and contributing positively to how the squad operates.

You understand your squad's context well enough to make real contributions, and you use that understanding to drive work forward — not just wait to be directed.

### Three dimensions

**1. Business Impact**
Understanding your squad's mission and how the work you're doing connects to it. Not just completing tickets — understanding why they matter, and letting that shape how you prioritise, what trade-offs you flag, and how you communicate progress. When something in your scope is heading in the wrong direction, you say so.

**2. Technical Excellence**
Delivering well-crafted, well-tested work. Taking ownership: caring about quality, thinking about edge cases, leaving the codebase in better shape. Growing in your ability to design systems and make sound engineering trade-offs with increasing independence.

**3. Contributing to the Team**
A positive, reliable presence. Useful, constructive code reviews. Engaging actively in discussions and sharing perspective. Asking good questions — including ones that surface problems others have missed. Starting to find ways to help less experienced teammates.

### Reflection questions

**How has your impact landed?**
- Where did you take ownership of a piece of work from start to finish — and what was the result?
- Did your understanding of the squad's priorities shape how you approached your work, or did you mostly execute what was defined?
- Where did you fall short, and what was in your control to change?
- Are you delivering work that's well-crafted and well-tested — and are you taking ownership of quality beyond just getting it done?
- Are you contributing to engineering standards — through code review quality, test coverage, and codebase health?
- Are your code reviews useful to the people who receive them? Are you sharing your perspective in discussions, not just listening?

**What would help you grow faster?**
- Where are you waiting to be told what to do, when you could be taking initiative?
- Is there an area where you're avoiding ownership because it feels uncomfortable — and what would help you step into it?
- What would it take for your squad to rely on you for something you're not yet trusted with?

### Suggested evidence signals

| Reflection area | Signal | MCP source | What to look for |
|----------------|--------|------------|-----------------|
| Ownership E2E | PRs authored with linked Jira tickets | GHE + Jira | PRs you drove from design through merge; epic-level ownership |
| Code quality | Review comments given | GHE | Constructive reviews on teammates' PRs; themes in your feedback |
| Initiative | PRs without assigned tickets | GHE | Work you identified and drove without being asked |
| Engineering standards | Test coverage trends | GHE | Test file changes relative to production code across your PRs |
| Squad priorities | DOD/epic alignment | Groove | Your work mapped to squad-level priorities and outcomes |
| Trade-off quality | Experiment results | Oliver | A/B tests you ran; metric movements; guardrail compliance |

### Looking ahead → Senior Eng

Identifying the hardest problems and helping the team solve them, not just contributing to what's already been scoped. Start building toward that — noticing where you can take more initiative, where you can help others, and where you can bring your own judgment to bear.

---

## Senior Eng

### Role definition

Driving significant efforts within your squad. Not just contributing — helping the squad deliver more by identifying the hardest problems, owning them end-to-end, and raising the capability of the people around you.

A role model within the squad. Consistently demonstrating great engineering judgment, being someone others learn from, and setting the standard by the quality of your work and how you show up.

### Three dimensions

**1. Business Impact**
Understanding your squad's mission and bringing that understanding into how you prioritise and make decisions. Identifying the most important problems for your squad to solve, not just the next ticket in the queue. When something is heading in the wrong direction, you raise it. You don't wait to be told what matters.

**2. Technical Excellence**
Holding a high bar within the squad. Well-crafted, well-tested code that leaves the codebase in better shape. Sound system design instincts applied in reviews, architecture discussions, and trade-off decisions. Clear ownership for the reliability and quality of what the squad builds and operates.

**3. Enabling Others**
Your presence raises the floor of your squad. Engineers learn from your code reviews, your approach to problems, and how you behave under pressure. Actively mentoring less experienced teammates — not just answering questions, but helping them grow. Creating psychological safety: people speak up, challenge ideas, and take risks because you've modeled that it's safe.

### Reflection questions

**How has your impact landed?**
- Where did your judgment and initiative shape your squad's direction in a meaningful way?
- Were there moments where you raised a risk or proposed a direction before being asked?
- Where did you fall short, and what was in your control?
- Are the systems your squad owns in better shape than six months ago — and what's your specific contribution?
- Are you consistently holding a high bar in code review, system design, and incident response?
- Are your teammates more capable engineers because of your involvement? Can you point to specific examples?
- Are you actively creating space for less experienced engineers to grow?

**What would make your impact matter more?**
- Not what your squad should do differently — what should you do differently as a Senior Engineer?
- Are you waiting to be handed the hardest problems, or identifying and proposing them yourself?
- Where are you staying in execution mode when you could be shaping direction?
- What is one thing you could do differently that would raise the capability of your squad, not just your own output?

### Suggested evidence signals

| Reflection area | Signal | MCP source | What to look for |
|----------------|--------|------------|-----------------|
| System health | SLO compliance, error budget | Oliver | SLO trends over 6 months for systems you own |
| System health | Incident rate, MTTR | Oliver + Jira | Incident count and resolution time for your components |
| Judgment & initiative | RFCs authored, design docs | Google Drive | Proposals you drove vs were assigned |
| Enabling others | Reviews given, mentoring signals | GHE | Volume + quality of reviews on others' PRs; pairing patterns |
| Enabling others | Slack recognition | Slack | Praise, thank-yous, knowledge-sharing threads you led |
| Reliability | On-call pages, alert noise | Oliver | Alert trends for components you own; noise reduction |
| Strategic direction | DOD/initiative alignment | Groove | Work mapped to bet-level priorities; direction you proposed |
| Cross-squad reach | Cross-repo PRs | GHE | Contributions outside your squad's primary repos |

### Looking ahead → Staff Eng

Driving significant efforts across squads within the studio — not just owning the hardest problems in your squad, but identifying and shaping the problems that matter across teams. The shift isn't primarily technical; it's about scope and initiative. The clearest signal isn't that you're the strongest engineer in your squad — it's that you're already operating meaningfully beyond it.

---

## Staff Eng

> **Source:** [Impact Talk: Staff Engineer [TEMPLATE]](https://docs.google.com/document/d/11HTPFEOWmN7kZEiN_Xbt_nz3D4euJnY84vUu5VxmU9U/)

### Role definition

Driving significant efforts within a studio, across squads. Your scope is not a single squad's roadmap — it's the technical landscape across multiple squads, and your job is to make that landscape better than you found it.

You don't wait for scope to be handed to you. You identify the biggest technical opportunities across teams, shape how those teams approach them, and influence decisions before they become costly to reverse. You are a role model in the studio — not by being the most senior person in the room, but by consistently demonstrating what great engineering judgment looks like in practice.

### Three dimensions

**1. Business Impact**
Identifying and working on the right cross-squad problems — not just executing within your squad's backlog. Your technical judgment shapes decisions that have real business consequences: architectural choices that accelerate delivery, investments in platform quality that reduce drag, technical calls that prevent expensive reversals. The question isn't "did I ship?" but "did I move the right things forward, and would the business be meaningfully different without my involvement?"

**2. Technical Excellence**
The systems across squads that you have a stake in are sound. You maintain a clear view of how systems fit together across the org — and you actively guide teams toward better design decisions and away from accumulating systemic debt. You're setting the bar on incidents: when something goes wrong, you're spotting the cross-squad patterns, not just solving the local problem. AI-era engineering standards are being raised through your work: test coverage, AI-assisted code review, codebases navigable for both humans and agents.

**3. Enabling Others and Community**
Your leverage isn't just the technical work you do — it's the capability you build in the engineers around you. You mentor, you share knowledge, you step in when engineers face hard problems or unfamiliar territory. You build technical community across teams through guilds, knowledge sharing, and modeling what great engineering culture looks like. The bar: are engineers around you measurably better at their craft because of your presence?

### Reflection questions

**How has your impact landed?**
- Where did your technical judgment shape decisions that had real business consequences?
- Where did you proactively raise a risk or propose a direction, leaving the work in better shape than you found it?
- What is different in the technical landscape because of your work — and how do you know?
- Are the cross-squad systems you have a stake in healthier than six months ago?
- Are you holding the bar on incidents beyond your own squad — identifying systemic patterns, not just fixing the immediate problem?
- How are you contributing to AI-era engineering standards across teams?
- Are engineers around you more capable because of your involvement? Can you point to specific examples?
- Where are you building technical community across squads — through guilds, knowledge sharing, or modeling engineering culture?

**What would make your impact matter more?**
- Are you creating your own scope, or mostly executing within scope that's been defined for you?
- Where are you influencing direction, and where are you just participating? Is that the right balance?
- Where would going deeper — being more opinionated, more present, more proactive — actually move things?
- When you have ideas and proposals for improving cross-squad work or processes, do you manage to get buy-in? Why or why not?
- What is one thing you could stop doing or delegate that would free you to operate at real cross-squad scope?

### Suggested evidence signals

| Reflection area | Signal | MCP source | What to look for |
|----------------|--------|------------|-----------------|
| Cross-squad impact | Cross-repo PRs and reviews | GHE | Contributions and reviews across multiple squads' repos |
| Technical landscape | Architecture docs, RFCs | Google Drive | Proposals that shaped cross-squad technical direction |
| Incident leadership | Cross-squad incident response | Oliver + Jira | Incidents where you identified systemic patterns beyond your squad |
| Community building | Guild leadership, talks, knowledge sharing | Slack + Google Drive | Guild sessions led, internal talks, shared documentation |
| Enabling others | Mentoring across squads | GHE + Slack | Reviews/pairing with engineers outside your squad; recognition from other teams |
| Strategic influence | Initiative/bet alignment | Groove | Work mapped to studio-level or org-level initiatives you shaped |
| Engineering standards | AI-era practices adoption | GHE | Test coverage, code review quality, codebase navigability improvements across teams |

### Expectations Sync agenda

**Section 1 — Reconnect on priorities and context (5 min)**
- What has shifted since we last synced?
- Are the cross-squad problems you're working on still the most important ones?
- Anything competing for your focus or unclear?

**Section 2 — The three big questions (20–25 min)**
Use the Reflection Questions above as the agenda for this section.

**Section 3 — Shared commitments (5 min)**
- Expected outcomes and markers for next half
- Key technical decisions or cross-squad efforts to lead
- Enabling others: who needs what from you this cycle
- What you need from me
- What success looks like before our next sync

---

## EM

> **Source:** [Impact Sync: Engineering Manager [TEMPLATE]](https://docs.google.com/document/d/1SMAdq4E5xCIyPNQbNXQEhlffjTLq7SlogpyRIqq6TLY/)

### Role definition

You own a squad — its people, priorities, and delivery — and your leverage comes from how well you connect the work to outcomes: the right problems chosen, engineers growing into harder challenges, and a team culture where accountability and psychological safety coexist.

### Three dimensions

**1. Business Impact**
Your squads are working on the right problems. You understand your domain deeply enough to drive technical direction that connects to the broader strategy. You translate business goals into concrete priorities your engineers can act on, and you articulate progress, tradeoffs, and risks back to leadership in terms they can act on. When priorities shift, you're assessing what it costs your team: what gets deprioritized, what resourcing changes, and what new risks emerge — and you're bringing that to the conversations.

**2. Technical Excellence**
You know how your squad's systems actually work — where they're strong, where they need investment, and how to keep production systems healthy. You're ensuring your team is making sound technical decisions: the right tradeoffs between speed and rigor, pragmatic approaches to tech debt, and code that's reviewable and maintainable. You're creating the conditions for your engineers to do their best technical work and enabling them to work effectively with AI tooling.

**3. Team, Culture, and Organization**
Your engineers have clear direction and psychological safety. They know what's expected, they understand why the work matters, and they feel safe raising concerns. You're developing your people — understanding where each person is in their growth, giving honest feedback, and creating opportunities that stretch them. Your senior engineers are leading technical decisions without waiting for you. Your more junior engineers are getting the support, mentorship, and context they need to grow into that autonomy. You're building a team that functions well when you're not in the room.

### Reflection questions

**How has your impact landed?**
- Did you define what "right" meant for your squad, or were you mostly executing on priorities handed to you?
- When priorities shifted, did you bring the tradeoffs, resourcing needs, and risks to leadership — or did you absorb the change silently?
- Were there moments where you could have pushed back or redirected your team's focus earlier than you did?
- Are the systems your team owns healthier than six months ago?
- Do you have a clear picture of the quality, risks, and production health of your squad's systems — or are there blind spots?
- Is your team making sound tradeoffs between speed and rigor, or are shortcuts accumulating that you haven't addressed?
- Are your engineers growing? Can your senior engineers lead technical decisions without waiting for you?
- Is there anyone on your team who is not on track, and are you being honest about that — with them and with yourself?
- Does your team function well when you're not in the room?
- Is your team coping with the priority shifts, ambiguity and AI-related pressure? Is there anything more you can do to help them?

**What would make your impact matter more?**
- Not what your squad should do differently — what should you do differently as an EM?
- Where are you too deep in execution details — reviewing every PR, sitting in every design discussion — when your engineers could own that?
- Where would going deeper actually raise the bar — being more present in a specific person's growth, more opinionated about your squad's technical direction, more deliberate about connecting the work to business outcomes?
- What is one thing you could stop doing, delegate, or hand to an engineer who's ready for it — that would free you to focus on the work only you can do?

### Suggested evidence signals

| Reflection area | Signal | MCP source | What to look for |
|----------------|--------|------------|-----------------|
| Squad delivery | Experiment outcomes, ship rate | Oliver + Jira | A/B tests shipped, metric movements, guardrail compliance for your squad |
| System health | SLO compliance, incident rate | Oliver | SLO trends and incident count for systems your squad owns |
| People growth | Promotion readiness signals | Jira + GHE | Engineers taking on harder work over time; increasing PR scope and ownership |
| Team culture | Sentiment in team channels | Slack | Engagement patterns, psychological safety signals, help-seeking behavior |
| Priority alignment | DOD/bet delivery | Groove | Squad outcomes mapped to studio-level priorities |
| Cross-team collaboration | Stakeholder communication | Slack + Google Drive | Proactive updates to partner teams; shared docs and decisions |
| Operational health | On-call burden per engineer | Oliver | Alert distribution, escalation rate, MTTR trends across your squad |

### Expectations Sync agenda

**Section 1 — Reconnect on priorities and context (5 min)**
- What has shifted since we last synced?
- Are current priorities still right in squad?
- Anything competing for your focus or unclear?

**Section 2 — The three big questions (20–25 min)**
Use the Reflection Questions above as the agenda for this section.

**Section 3 — Shared commitments (5 min)**
- Expected outcomes and markers for next half
- Key decisions to drive or tradeoffs to manage
- People / team: who needs what from you this cycle
- What you need from me
- What success looks like before our next sync

---

## Senior EM

> **Source:** [Impact Talk: Senior Engineering Manager [TEMPLATE]](https://docs.google.com/document/d/16yUETQ_qKTbytdKM0Y539T7XHUFwRtilkTZegpok_ts/)

### Role definition

The SEM role sits between Engineering Manager and Director. You are responsible for multiple squads — likely managing through EMs or tech leads — and your leverage comes from the systems you put in place across those teams: clear priorities, strong people, healthy engineering culture, and technical direction that does not require you in every room. The career steps framework defines the ceiling: a Director owns an org-level direction, manages a management chain, and shapes strategy across the full breadth of their scope. As a SEM, you are accountable for a meaningful portion of that — and the highest-leverage thing you can do is build toward it.

### Three dimensions

**1. Business Impact**
Your squads are working on the right problems. Your EMs understand how the technical work their teams own connects to the broader strategy — and they can articulate that without you in the room. When priorities shift, you are the one adjusting direction across your teams, not waiting to be told.

**2. Technical Excellence**
The systems your teams own are sound. You are holding the bar on tech health across multiple squads — not just within each squad individually. You are calibrating speed and rigor: fast and iterative on early-stage and experimental work; more disciplined on platform and foundational systems. AI-era engineering standards are being adopted: test coverage is growing, AI-assisted code review is the norm, codebases are navigable for both humans and agents.

**3. Team, Culture, and Organization**
Your EMs have clear direction and psychological safety. They are developing as decision-makers, not just executors — they should be able to hold direction and make meaningful calls without you in the room. You are tracking each person's growth and actively creating space for it. You are not a bottleneck for squad-level decisions. Where you are a bottleneck, you know it and have a plan.

### Reflection questions

**What impact are we here to drive over the next 3–6 months?**
- What specifically will be different in the technical areas and systems your squads own?
- Name the business outcomes, the architectural state changes, and the engineering capability shifts you will want to drive.
- Which of those require you to set direction personally vs. which can your EMs own end-to-end?
- Are there cross-squad or cross-functional bets where your involvement is the thing that unlocks progress?

**How has your impact landed?**
- *Business Impact:* Where did you guide your squads toward what matters for the broader strategy? Were there moments where you shaped direction before leadership had to pull it from you? Where did you fall short, and what was in your control?
- *Technical Excellence:* Are the systems your teams own healthier than six months ago? Is speed being calibrated appropriately — fast where we need to be, more rigorous where it counts? How are we tracking toward AI-era engineering standards across your squads (adoption, test coverage, code review)?
- *Team, Culture, and Organization:* Are your EMs developing as decision-makers? Can they hold direction and make calls without you? Are there squads or people where you are more of a bottleneck than you should be? Who on your team specifically needs more from you right now? Who is ready for more autonomy and challenge? Are there people on your team who are not on track, and are you being honest about that — with them and with yourself?

**What would make your impact matter more?**
- Not what your teams should do differently — what should you do differently as a SEM?
- Where are you staying too deep in the weeds of squad-level execution, and what would leveling up look like?
- Where would you going deeper — being more present, more opinionated — actually unblock things or drive more impact?
- What is one thing you could stop doing, delegate, or change that would free you to operate at a higher level?

### Suggested evidence signals

| Reflection area | Signal | MCP source | What to look for |
|----------------|--------|------------|-----------------|
| EM development | Growth patterns across your EMs | Jira + GHE | EMs' squads taking on harder work, increasing ownership, improving delivery metrics |
| Organizational health | Cross-squad metrics | Oliver | SLO trends, incident rates, deployment frequency across all squads |
| Strategic alignment | Multi-squad DOD delivery | Groove | Organization-level outcomes mapped to studio/mission priorities |
| Staffing and org design | Hiring and team composition | Jira + Slack | Hiring pipeline outcomes, team composition changes, mobility decisions |
| Cross-org collaboration | Leadership communication | Slack + Google Drive | Alignment docs, cross-org decision threads, strategy contributions |
| Culture at scale | Team-level engagement in squad channels | Slack | Team-level aggregate patterns across multiple squads (do not surface individual messages) |

### Expectations Sync agenda

**Section 1 — Reconnect on priorities and context (5 min)**
- What has shifted since we last synced?
- Are current priorities still right across your squads?
- Anything competing for your focus or unclear?

**Section 2 — The three big questions (20–25 min)**
Use the Reflection Questions above as the agenda for this section.

**Section 3 — Shared commitments (5 min)**
- Expected outcomes and markers for next half
- Key decisions to drive or tradeoffs to manage
- People / team: who needs what from you this cycle
- What you need from me
- What success looks like before our next sync

---

## Director

> **Derivation notice:** This template was derived from the [Career Steps for Engineering Management](https://docs.google.com/document/d/1zVMboZel1a3l9yKjm860SfDn2LGGAbs-4HwqCzX8za4/) doc (deprecated April 2026). No published PZN template exists for this role. The content is structured around the current Performance@Spotify WHAT × HOW framework. It will be updated when the EM Expectations model (announced for May 2026 by the XTL, not yet confirmed as published) is available.

### Role definition

You lead an organization — its leaders, its strategy, and its business impact. Your primary focus is on long-term vision, strategy, and growing the leaders who grow the teams. You work with peers across the company to ensure that your organization's mission and vision are aligned with overall company strategy, and you actively articulate what your organization needs from others (tooling, infrastructure, features, partnerships) to deliver on its goals.

At this level, nearly all of your impact is through the people and structures you put in place. The business complexity of your organization and the impact you have on it are what define this role.

### Three dimensions

**1. Business Impact**
You set the strategic direction for your organization and ensure it aligns with company-level goals. You work with peers across missions to identify cross-organizational opportunities and dependencies. You translate company strategy into a clear vision that your Senior EMs and EMs can execute against. You are accountable for the business outcomes of your organization — not just delivery, but whether the work produced the intended business impact.

**2. Technical Excellence**
You ensure that your organization's technical strategy supports long-term business goals. You do not make individual technical decisions, but you ensure the right people are making them and that the decisions are sound. You champion investment in technical health, platform quality, and engineering standards when short-term business pressure pushes against it. You ensure your organization's systems are resilient, well-maintained, and positioned for the future.

**3. Growing Leaders and Shaping Culture**
You grow role models and leaders. Your Senior EMs and EMs are your primary focus — their development and effectiveness determine your organization's capability. You set the cultural tone for your organization: what behaviors are valued, how decisions are made, how conflicts are resolved, how accountability works. You ensure that your organization attracts, develops, and retains strong talent at every level.

### Reflection questions

**How has your impact landed?**
- Is your organization delivering meaningful business outcomes — and can you draw a clear line from your strategic decisions to those outcomes?
- Are your leaders growing? Are your Senior EMs and EMs more capable than they were six months ago?
- Are you working effectively with peers across missions to align strategy and resolve dependencies?
- Is the technical health of your organization improving, or is short-term pressure eroding it?
- Does the culture of your organization reflect what you intend — accountability, psychological safety, clarity of purpose?
- Are there strategic bets you should have made but did not, or bets you should have stopped but let continue?

**What would make your impact matter more?**
- Where are you operating at the EM or Senior EM level when you should be operating at the organizational level?
- Are you shaping company-level strategy, or primarily executing within the strategy others define?
- What one change to your organization's structure, staffing, or priorities would have the largest impact on outcomes?
- Where would being more decisive — making a call earlier, redirecting resources, changing a leader's scope — move things forward?

### Suggested evidence signals

| Reflection area | Signal | MCP source | What to look for |
|----------------|--------|------------|-----------------|
| Organizational outcomes | Business metrics for your org | Oliver + BigQuery | Experiment outcomes, user metrics, delivery velocity across the organization |
| Leader development | SEM/EM growth trajectory | Jira + GHE | Leaders taking on broader scope, improving their organizations' metrics |
| Strategic alignment | Organization-to-company alignment | Groove | Organizational bets mapped to company-level strategy |
| Cross-mission collaboration | Peer alignment and dependencies | Slack + Google Drive | Strategic alignment docs, cross-mission decision threads |
| Technical health at scale | Organization-wide system health | Oliver | SLO trends, incident rates, platform investment across the organization |
| Talent and culture | Retention, hiring, team health | Slack | Organization-level aggregate patterns (do not surface individual messages) |

### Expectations Sync agenda

**Section 1 — Reconnect on priorities and context (5 min)**
- What has shifted at the company or mission level?
- Are current organizational priorities still right?
- Any strategic dependencies or cross-mission dynamics to address?

**Section 2 — The three big questions (20–25 min)**
Use the Reflection Questions above as the agenda for this section.

**Section 3 — Shared commitments (5 min)**
- Expected organizational outcomes for next half
- Key strategic decisions to drive
- Leader development: which leaders need what from you
- What you need from your leadership
- What success looks like before our next sync

---

## Custom template

Users who prefer their own format can configure a custom template:

```json
{
  "career_level": "custom",
  "custom_template": "path/to/template.md"
}
```

Or via Google Doc URL:
```json
{
  "career_level": "custom",
  "custom_template": "https://docs.google.com/document/d/..."
}
```

When `career_level` is `custom`, `prep` reads the user's template at inference time and uses its structure to guide the reflection questions in Step 2. The template should define the dimensions and questions the user wants to reflect on — there is no required format.

If the template is a Google Doc, `prep` reads it via `google-drive-mcp` (if configured) or `gcloud` Docs API fallback.
