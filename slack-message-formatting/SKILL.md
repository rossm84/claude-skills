---
name: slack-message-formatting
description: Use when composing Slack messages via MCP tools (slack_send_message, slack_send_message_draft). Use when messages render as walls of text, lose formatting, or blank lines get stripped. Use when the user complains about message layout.
---

# Slack Message Formatting via MCP Tools

## The Core Problem

Both `slack_send_message` and `slack_send_message_draft` strip all blank lines. You cannot create paragraph spacing. Blockquotes (`>`) merge into one continuous left-bar. The only element that creates visual separation is a code block.

## What Works

- `*bold*` — renders (NOT `**bold**`)
- `_italic_` — renders
- `` `inline code` `` — renders
- Code blocks (triple backtick with newline after opening) — renders as a visual box
- `<url|display text>` — renders as link
- `<@U123456>` — renders as mention

## What Does NOT Work

- Blank lines for spacing — stripped by both send and draft APIs
- `>` blockquotes for sections — merges into one continuous left-bar quote
- `## Headers` — not supported
- `---` horizontal rules — literal text
- Tables — not supported
- Syntax highlighting — ignored

## The Pattern: Main Message + Thread Replies

Do NOT attempt multi-section messages. They collapse into walls of text.

Instead, split every structured message into:

1. *Main message:* 2-3 sentences max. The key point, bolded terms, and "Detail in thread below."
2. *Thread replies:* One reply per section (mapping, code, notes). Each focused on one topic.

Use `thread_ts` from the main message response to post replies.

## Example

*Main message:*
```
You don't need `metrics_agg`. The table powering the Ops Deck is `cs-analytics-dev.tableau_views.cs_ops_data_glue` — it has all 5 metrics plus a `target_delta` column. So "red" is just `WHERE target_delta < 0`. Detail in thread below.
```

*Thread reply 1 — mapping:*
```
*Metric mapping*
SLA → `service_response_time_hit_rate`
Resolution → `survey_resolution`
```

*Thread reply 2 — code:*
```
*The query*
\`\`\`
SELECT * FROM table WHERE condition
\`\`\`
```

*Thread reply 3 — notes:*
```
*Worth knowing*
- First caveat
- Second caveat
```

## Quick Reference

- Bold: `*text*` (single asterisk)
- Italic: `_text_`
- Links: `<url|display text>` not `[text](url)`
- Mentions: `<@U123456>` for users, `<#C123456>` for channels
- No headers, no rules, no tables, no syntax highlighting
- No blank line spacing — stripped by API
