---
name: slack-message-formatting
description: Use when composing Slack messages via MCP tools (slack_send_message, slack_send_message_draft). Use when messages render as walls of text, lose formatting, or blank lines get stripped. Use when the user complains about message layout.
---

# Slack Message Formatting via MCP Tools

## The Core Problem

Both `slack_send_message` and `slack_send_message_draft` strip all blank lines. You cannot create paragraph spacing. Messages that look structured in your editor render as walls of text.

## What Renders

- `*bold*` — works (NOT `**bold**`)
- `_italic_` — works
- `` `inline code` `` — works
- Code blocks (triple backtick with newline after opening) — works, creates a visual box
- `<url|display text>` — works for links
- `<@U123456>` — works for mentions

## What Does NOT Render

- Blank lines for paragraph spacing — stripped completely
- `>` blockquotes for section separation — merges into one continuous left-bar
- `## Headers` — not supported in Slack
- `---` horizontal rules — renders as literal text
- Tables — not supported
- Syntax highlighting in code blocks — ignored

## The Only Working Approach

*Keep messages short and conversational.* Do not attempt multi-section structured layouts — they will collapse into walls of text.

For messages with technical detail, split into two parts:
1. *Main message:* Short, flowing text (2-3 sentences max) with `*bold*` for key terms
2. *Thread reply:* Post the code, data, and detailed notes as a reply

Code blocks are the ONLY element that creates visual separation. Use them for code, but do not abuse them for non-code content.

## Template

Main message:
```
Short summary with *key point* bolded. One more sentence of context. Detail is in the thread below.
```

Thread reply (use `thread_ts` parameter):
```
*Metric mapping*
SLA → `service_response_time_hit_rate`
Resolution → `survey_resolution`

*The query*
\`\`\`
SELECT * FROM table
WHERE condition = true
\`\`\`

*Notes*
First note about something important.
Second note about a caveat.
```

The thread reply will also lose blank lines, but that matters less because threads are expected to be denser and readers are already in "detail mode."

## Slack mrkdwn Quick Reference

- Bold: `*text*` (single asterisk)
- Italic: `_text_`
- Links: `<url|display text>` not `[text](url)`
- User mention: `<@U123456>`
- Channel mention: `<#C123456>`
- No headers, no rules, no tables, no syntax highlighting
