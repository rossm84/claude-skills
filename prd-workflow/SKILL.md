---
name: prd-workflow
description: Use when starting a non-trivial feature, refactor, or multi-file change, before any code is written. Captures decisions to ~/prds/{slug}/prd.md via a 3 to 5 round multi-choice spec interview, then optionally dispatches to Jira tickets and git worktrees. Prevents the agent from inventing the "what" while implementing the "how", and survives compaction by keeping the spec on disk.
---

# PRD-Driven Feature Spec

Adapted from Brandon Newton's writeup on `/prd` from the disco-claude-resources plugin. Use this when about to start a multi-file change, a service refactor, or any feature where the wrong "what" is more dangerous than slow "how".

## When to use

- User asks for a feature or refactor that touches more than one file or service.
- A spike doc, ticket, or stakeholder brief exists and the next step is implementation.
- Earlier conversations about an approach risk being lost to compaction or new sessions.
- About to enter Plan mode for non-trivial work.

Do NOT use this for: typo fixes, single-file tweaks, exploratory spikes where throwing the code away is the point, or anything where the user has already paid the spec cost elsewhere and wants to start coding.

## Why bother

AI agents are great at the *how* and happy to invent the *what*. Without a written spec, ambiguous decisions get quietly papered over and only surface in code review when the diff is three days deep. The PRD forces the user to commit to concrete decisions before any code exists.

It also survives compaction. Long sessions auto-summarise earlier turns, and the lossy summary is what survives. A PRD file lives outside the conversation, so a `cat ~/prds/{slug}/prd.md` rehydrates the exact spec on day three or in a fresh session.

## The flow

### 1. Locate or create the PRD

```
~/prds/{feature-slug}/prd.md
```

`{feature-slug}` is lowercase-kebab-case, derived from the feature name. The PRD lives **outside any repo**, because most features touch multiple services. If the user has a personal `~/prds` GHE repo, every edit auto-commits and pushes. Don't put PRDs inside the project repo.

If a PRD for this slug already exists, open it, summarise the current state, and ask whether this is a continuation, an amendment, or a new related PRD.

### 2. Pull context before asking anything

Run these in parallel:

- **Google Docs** mentioned by the user via the Drive MCP (`get_drive_file_content`, `get_document_section`)
- **Slack threads** referenced via `slack_read_thread` or `slack_search_*`
- **Code** via `grep` and `Read` on the relevant files. Capture file:line citations.
- **Related PRDs** in `~/prds` via `ls ~/prds/` and `grep` if useful.

Then write a one-paragraph "what we know" summary at the top of the PRD draft so the user can correct it before the interview starts.

### 3. Interview the user

**Format**: 3 to 5 rounds. Each round uses `AskUserQuestion` to batch 2 to 4 multi-choice questions. **No prose questions, no yes/no.** Always include an "Other" option that makes the skill rewrite the question on selection.

Cover ground that is otherwise easy to fudge:

- **Auth posture** (which scopes, which token path, which roles)
- **Pagination shape** (offset/cursor, default page size, max page size)
- **Error envelope** (shared with which existing API, which fields)
- **Enum values** (exact string list, casing, future-proofing)
- **Rollout** (feature flag, gradual percentage, kill switch)
- **Failure modes** (what's retryable, what's idempotent, what raises)
- **Non-goals** (the things people will assume are in scope but aren't)
- **Launch criteria** (what "done" actually means)

Adjust the topics to the feature. Aim to surface the things the user hadn't actually thought through. About a quarter of the questions should hit that mark.

Edit the PRD between rounds so no decision is lost to compaction.

### 4. Write the PRD to a strict template

```markdown
# {Feature Title}

**Slug:** {feature-slug}
**Owner:** {user}
**Status:** Draft / In progress / Shipped / Archived
**Last updated:** {ISO date}

## Background
What is this and why now. Two to four sentences. Link the spike doc, ticket, and any prior PRDs.

## Goals
What this PRD commits to delivering. Bulleted, concrete.

## Non-goals
What this PRD explicitly does not deliver, even if related. Equally bulleted, equally concrete.

## Current state
What exists today, with `path/to/file.py:42` style citations for the bits that matter. Screenshots or curl examples welcome.

## Proposed approach
The chosen approach, expressed as the diff against current state. Include shape of new APIs, new files, new database columns, new flags.

## Alternatives considered
Each alternative as a one-liner with its tradeoff. Two to four is plenty.

## Risks
Known unknowns. What could go wrong, what mitigates it.

## Testing
Unit + integration + manual coverage. Specific scenarios, not "we'll write tests".

## Launch criteria
The list that has to be true before flipping the flag. Include the rollout plan and kill switch.

## Tasks
Numbered list. Each task is one PR's worth of work, scoped tight enough to ship in a day. Each gets a working title, a one-line outcome, and the files it expects to touch.
```

### 5. Lock in the task list, then optionally dispatch

When the task list looks right, ask the user whether to dispatch. Dispatching means:

- Each task becomes a Jira ticket linked to the PRD
- Each task gets a git worktree off the relevant repo's main branch
- The user works one task at a time with a clean workspace per branch

If dispatching, the user runs the appropriate dispatch command for their tooling. The original disco-core plugin uses `/disco-core:dispatch <slug>`. If the user doesn't have disco-core installed, hand back the task list as a numbered checklist and stop.

### 6. Maintenance

When scope shifts mid-implementation, re-run this skill on the same slug. The PRD is the source of truth, the tickets are downstream. Update the PRD first, regenerate or amend tickets second.

## What good output looks like

- File:line citations in the Current state section, not vague references.
- Non-goals that name specific things ("does not change the existing v1 endpoint shape").
- Enum values listed verbatim, casing locked.
- Each task is a single PR, not a five-PR umbrella.
- The launch criteria are checkable on the day, not aspirational.

## Anti-patterns

- **Prose questions in the interview.** The user will write three sentences and you'll still not have a decision. Multi-choice forces commitment.
- **Yes/no questions.** Same problem, just shorter.
- **Skipping the context pull.** The interview asks worse questions when you haven't read the code first.
- **Putting the PRD inside the project repo.** It locks the spec to one service when the work spans many.
- **Treating the PRD as final after the first dispatch.** It's a living doc; the first version always misses something.

## Reference

Source writeup: Brandon Newton, "How I use /prd to steer my context engineering work" (2026-05-05). The original `/prd` skill lives in the `creator/disco-claude-resources` plugin.
