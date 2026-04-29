---
name: reply-to-dm
description: Use when Ross pastes a Slack DM URL or channel ID and says "help me reply" / "draft a response" / "see the latest" / similar. Reads the thread, pulls context from Jira/Drive/Confluence/Bandmanager as needed, drafts a reply as a Slack draft for Ross to review. Do not send — always save as draft.
---

# Replying to a Slack DM

Ross's recurring pattern: he pastes a Slack URL (DM or channel) and asks for help replying. Follow this exact workflow.

## Steps

### 1. Read the thread

Extract the channel ID from the URL (e.g. `https://spotify.enterprise.slack.com/archives/C0ALBGG8FBN` → `C0ALBGG8FBN`).

Use `mcp__claude_ai_Slack_MCP__slack_read_channel` with `limit: 10–15` to see the latest messages. If the conversation is threaded, also call `slack_read_thread` with the parent `message_ts`.

### 2. Identify the ask

Read Ross's last message and the other party's most recent. Figure out:
- What is the person asking for / waiting on?
- Has Ross already said anything that commits him to an action?
- Is there a deadline / urgency?

### 3. Pull context (only what's needed)

Do NOT dump context for context's sake. Pull only what's necessary to answer the ask correctly. Common sources:

- **Jira**: `mcp__claude_ai_Atlassian_Rovo__searchJiraIssuesUsingJql` or `getJiraIssue`. Ross's board is `CPM` (cloudId `dc26f8aa-beba-4ac1-b55d-2f47ce01551f`).
- **Confluence**: `searchConfluenceUsingCql` for existing docs in space `CSPl`.
- **Google Drive**: `mcp__claude_ai_GDrive_MCP__get_document_preview` or `get_document_structure`.
- **Bandmanager**: `mcp__claude_ai_Bandmanager_MCP__*` for people/group lookups.
- **Memory**: Always check `~/.claude/projects/-home-rossmiller/memory/MEMORY.md` for pre-existing context on the topic.
- **Prior Slack threads**: `slack_search_public_and_private` if there's older context Ross alludes to.

### 4. Draft the reply

**Hard rules:**
- Save as draft via `mcp__claude_ai_Slack_MCP__slack_send_message_draft`. Never send directly — the `feedback_slack_approval` memory is explicit.
- Use Slack mrkdwn: `*bold*` (single asterisks), `` `code` ``, `<url|label>`, bullets with `•` or `-`.
- Voice: Ross is Scottish (see `user_ross_scottish.md`). Don't fake the accent but lean warm + direct, not corporate. No em-dashes (see `feedback_no_dashes.md`).
- Lead with the point in line 1. If correcting someone, be gentle but factual — don't soften with flattery.
- For technical context, link the actual source (Jira ticket, Doc, Confluence page) rather than re-explaining.

### 5. Report back

Return to Ross with:
- Link to the draft channel: `https://spotify.enterprise.slack.com/archives/<channel_id>`
- 1-2 sentences on what the reply does
- Anything you left out that he might want to add (names, numbers, dates you didn't fabricate per `feedback_no_fabrication`)
- Flags for anything the draft commits Ross to (e.g. "this says you'll send the token separately — you'll need to actually DM it")

## Never

- Never send the message without Ross typing "send" explicitly. Draft only.
- Never invent names, emails, ticket numbers, or Slack IDs. If you need one and don't have it, say "I don't know".
- Never paste secrets (tokens, API keys) in the draft body unless Ross has explicitly authorized that specific value to that specific destination. Even then, suggest a secure-link alternative (1Password/Coda) first.

## When to skip this skill

- Pure Slack search / lookup questions (use `slack-search` skill instead).
- Composing a brand-new message from scratch, not a reply (use `slack:draft-announcement`).
- Reading a thread for summary only, no reply needed.
