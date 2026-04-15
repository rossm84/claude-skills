---
name: guru-knowledge-base
description: Search, retrieve, and manage Guru knowledge base cards via the Guru MCP server. Use when asked about Guru card content, knowledge coverage, conflicts, gaps, or when creating or updating Guru cards.
---

## Guru MCP Server

Base URL: `https://mcp.api.getguru.com/mcp`
Auth: OAuth (configured in .mcp.json)

---

## Important: Always Call guru_list_knowledge_agents First

Both `guru_search_documents` and `guru_answer_generation` require an `agentId`.
Always call `guru_list_knowledge_agents` at the start of every session to get the available agent IDs before using any other tool.

---

## Available Tools

### 1. guru_list_knowledge_agents
Get available knowledge agents and their IDs.
Call this first — both search and answer tools require an agentId.

```
guru_list_knowledge_agents()
```

Returns: list of agents with their IDs and names. Note the agentId for use in subsequent calls.

---

### 2. guru_search_documents
Search for existing cards and documents by keyword. Returns a list of documents to browse — not a direct answer.

```
guru_search_documents(
  query: "your search term",
  agentId: "AGENT_ID_FROM_STEP_1"
)
```

Optional parameters:
- `collectionIds` — limit search to specific Guru collections
- `sourceIds` — limit search to specific sources

Use this when you need to find which cards exist on a topic, retrieve card IDs for further actions, or check source coverage for the Command Center.

---

### 3. guru_answer_generation
Ask a question and get a direct AI-generated answer from the Guru knowledge base. Use when you need a synthesised answer rather than a list of documents.

```
guru_answer_generation(
  question: "What is our refund policy?",
  agentId: "AGENT_ID_FROM_STEP_1"
)
```

Optional parameters:
- `collectionIds` — limit to specific collections
- `sourceIds` — limit to specific sources

Use this for conflict detection — ask the same question twice, once scoped to Guru and once scoped to SuSi or Community, and compare the answers.

---

### 4. guru_get_card_by_id
Fetch the full HTML content of a specific card by its ID. Always call this before updating a card to preserve its existing HTML structure.

```
guru_get_card_by_id(
  id: "CARD_ID"
)
```

Returns: full card content including title, HTML body, collection, tags, last modified date, and verification state.

Key fields for the Command Center:
- `preferredPhrase` — card title (used for topic normalization)
- `content` — full HTML body (used for conflict/gap detection)
- `lastModified` — freshness date
- `lastVerified` — verification date (use whichever is more recent for freshness score)
- `verificationState` — TRUSTED / NEEDS_VERIFICATION / UNVERIFIED
- `collection.name` — which collection the card belongs to
- `tags` — topic tags for cross-referencing with SuSi and Community

---

### 5. guru_create_draft
Create a new draft card in Guru with a title and content. Use when a gap is detected and a new card is needed.

```
guru_create_draft(
  title: "Card title here",
  content: "<p>Card content in HTML</p>"
)
```

Note: creates a draft only — does not publish. A Guru author or admin must review and publish.

---

### 6. guru_update_card
Update an existing card's title and/or content. Always call guru_get_card_by_id first to retrieve current content before updating — this preserves the card's HTML structure.

```
guru_update_card(
  cardId: "CARD_ID",
  title: "Updated title",
  content: "<p>Updated HTML content</p>"
)
```

---

## Standard Workflows

### Coverage check (Command Center daily poll)
```
1. guru_list_knowledge_agents()                    -> get agentId
2. guru_search_documents(query, agentId)           -> find cards on topic
3. guru_get_card_by_id(id)                         -> get full content + metadata
4. Compare against SuSi MCP and Khoros results     -> run conflict/gap detection
```

### Conflict detection
```
1. guru_list_knowledge_agents()                    -> get agentId
2. guru_answer_generation(question, agentId)       -> get Guru's answer on topic
3. Compare against SuSi MCP answer on same topic   -> identify factual/procedural conflicts
4. Note lastModified dates on both sides           -> use most recent as reference source
```

### Freshness check
```
1. guru_search_documents(query, agentId)           -> find card
2. guru_get_card_by_id(id)                         -> retrieve lastModified + lastVerified
3. Use whichever date is more recent               -> calculate freshness_days
4. Apply freshness band: <30d green / 30-180d yellow / 180d+ red
```

### Gap fill — create new card
```
1. Confirm gap exists via guru_search_documents    -> no results on topic
2. guru_create_draft(title, content)               -> create draft
3. Flag for human review before publishing
```

### Update existing card
```
1. guru_search_documents(query, agentId)           -> find card ID
2. guru_get_card_by_id(id)                         -> retrieve current HTML content
3. guru_update_card(cardId, title, content)        -> apply updates preserving HTML structure
```

---

## Known Behaviours

- `agentId` is required for search and answer generation — never skip `guru_list_knowledge_agents`
- `guru_update_card` without first calling `guru_get_card_by_id` risks overwriting or breaking the card's HTML structure
- `guru_create_draft` does not publish — always flag created drafts for human review
- Card content is returned as HTML — strip tags when passing to AI prompt chain for conflict/gap analysis
- `verificationState` values: `TRUSTED` (verified), `NEEDS_VERIFICATION` (due for review), `UNVERIFIED` (never verified)
- For freshness scoring, use `MAX(lastModified, lastVerified)` — whichever is more recent

---

## Collections Reference

Run `guru_list_knowledge_agents` to discover available collections and their IDs for your workspace.
Scope searches to the CSKM collection to limit results to relevant cards.

---

## Questions?
Contact your Guru admin or refer to the Guru MCP documentation at:
https://developer.getguru.com/docs/guru-mcp-server-overview
