---
name: tapestry
description: Use when connecting, cross-referencing, or synthesizing information across multiple documents, memory files, or knowledge sources. Maps relationships between documents and surfaces gaps or contradictions.
---

# Tapestry -- Document Interlinking and Synthesis

Connect related documents, surface relationships, and find gaps across a body of knowledge.

## When to use
- Checking if multiple docs/memories tell a consistent story
- Finding which documents relate to a topic
- Surfacing gaps (things mentioned but never documented)
- Preparing a synthesis across multiple sources
- Auditing a set of docs for completeness

## Process

### 1. Gather sources
Identify all relevant documents. Common locations:
- `~/.claude/projects/-home-rossmiller/memory/` -- project memory files
- `docs/` -- project documentation
- Google Docs (via gsuite-cli or GDrive MCP)
- Backstage TechDocs
- Slack threads (via Slack MCP)

### 2. Extract entities and claims
For each document, pull out:
- **Key entities**: people, systems, dates, decisions
- **Claims**: factual statements that could be verified or contradicted
- **References**: links to other documents, `[[memory-name]]` links, URLs
- **Open questions**: things marked TBD, pending, blocked

### 3. Build a relationship map
Cross-reference entities across documents:
```
Document A mentions: "merge freeze begins 2026-03-05"
Document B mentions: "PR #7068 merged 2026-03-05"
→ Contradiction? Or was the PR merged before the freeze?
```

### 4. Surface findings

**Connections**: Documents that reference each other or share entities
**Contradictions**: Conflicting facts across documents
**Gaps**: Entities mentioned but never defined; decisions referenced but never documented
**Staleness**: Documents with claims that are no longer true (check dates, verify against current state)

### 5. Output format

```markdown
## Tapestry Report: [Topic]

### Sources reviewed
1. [doc name](path) -- one-line summary

### Key connections
- A ↔ B: both discuss [topic], A has the decision, B has the implementation

### Contradictions
- A says X, B says Y (which is correct?)

### Gaps
- [Entity] mentioned in A but never documented elsewhere
- [Decision] referenced but no doc captures the rationale

### Staleness
- A claims [fact] but current state shows [different fact] -- update needed
```

## Tips
- Start with memory files (`MEMORY.md` index) for a quick overview of what's documented
- Use `grep -r "keyword" ~/.claude/projects/-home-rossmiller/memory/` to find mentions across memories
- Cross-reference with `git log` for timeline accuracy
- When fixing contradictions, prefer the source closest to the event (commit message > memory > summary doc)
