---
name: slack-message-formatting
description: Use when composing Slack messages via MCP tools (slack_send_message, slack_send_message_draft). Use when messages render as walls of text, lose formatting, or blank lines get stripped. Use when the user complains about message layout. Complements the slack:slack-messaging skill with MCP-specific fixes.
---

# Slack Message Formatting via MCP Tools

## The Problem

The Slack MCP draft/send tools strip consecutive blank lines. Messages that look structured in your editor render as collapsed walls of text.

## Slack mrkdwn vs Markdown

Slack uses `mrkdwn`, NOT standard Markdown. Key differences:

- Bold: `*text*` not `**text**`
- Italic: `_text_` not `*text*`
- Links: `<url|display text>` not `[text](url)`
- User mention: `<@U123456>`
- Channel mention: `<#C123456>`
- No headers (`##`), no horizontal rules (`---`), no tables, no syntax highlighting

## The Blockquote Pattern

Blank lines get stripped by the API. `>` blockquotes are the only reliable way to create visual sections — they render as indented boxes that force separation regardless of whitespace stripping.

Structure every multi-section message like this:

```
Summary sentence — the key takeaway.

Context in 1-2 sentences.

> *Section One*
> Line one
> Line two

> *Section Two*
> Line one
> Line two

Closing sentence with next steps.
```

Plain text between blockquoted sections creates natural visual breathing room even when blank lines collapse.

## Code Blocks

Put a newline AFTER opening triple backticks — without it the first line gets swallowed.

## Message Structure

1. Lead with the point — first line shows in mobile notifications
2. Keep main message to 1-3 short paragraphs — put details in a thread reply
3. Wrap each logical section in `>` blockquotes
4. Use `*bold*` for key terms, names, dates, action items
5. Use `-` for bullet lists (avoid `*` — conflicts with bold)

## Common Mistakes

- `**double bold**` → use `*single bold*`
- `---` separator → use `>` blockquotes for sections
- Blank lines for spacing → use `>` blockquotes (blank lines get stripped)
- Language after triple backticks → remove it (Slack ignores it)
- Very long message → split into main message + thread reply
- `[text](url)` links → use `<url|text>` format
