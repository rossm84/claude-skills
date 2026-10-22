# Zero-MCP and First-Run MCP Onboarding (Claude Code)

## First-run MCP onboarding (skip if config file exists)

The entire value of Preflight depends on connected sources. If MCPs
are missing on first run, guide setup **before** producing the briefing.

**Opening message:**

> "Preflight pulls your calendar, Slack, and meeting docs into a
> 2-minute daily briefing. Let me connect your sources first — each
> takes about 30 seconds."

Walk through each missing MCP in priority order:

| Priority | MCP | Why first |
|---|---|---|
| 1 | Slack | Highest immediate value — surfaces threads needing response |
| 2 | Google Workspace (`gws-mcp`) | Calendar, meeting docs, and comments — one server |

For each missing MCP, use `AskUserQuestion`:
- "Connect [Slack / Google Workspace]? [1-sentence value pitch]"
- Options: "Yes, connect it" / "Skip for now"

If confirmed, walk through setup. When presenting URLs to the user,
output them as **bare URLs on their own line** — not inside code blocks,
backticks, or markdown link syntax. Bare URLs render as clickable
hyperlinks in the terminal.

MCP Gateway URLs:
- Google Workspace: `https://mcp-gateway.spotify.net/gws-mcp`
- Slack: `https://mcp-gateway.spotify.net/slack-mcp`

Re-auth Google Workspace:
https://backstage.spotify.net/mcp-explorer/link/gws-mcp

Call `execute_tool` on `user-gws-mcp`. Calendar is `gcal.list_events`.
Docs are `gdocs.get_document` with `document_id`. Search is
`gdrive.search_files`. Do not link `google-calendar-mcp` or
`google-drive-mcp`.

For Claude Code setup (run in a **separate terminal**):
```bash
claude mcp add --transport http --scope user [name] [url]
```

Link account (output as bare URL):
https://backstage.spotify.net/mcp-explorer

Setup guide:
https://backstage.spotify.net/docs/default/component/ai-hub/tools/spotify-approved-mcp-servers/

After setup, re-test the MCP with the same lightweight call. If it
responds, proceed to the next. If the user must restart, say:
"Restart and say 'preflight' again." Save partial progress to
`.preflight-state.md`.

If the user skips all MCPs → follow the zero-MCP flow below.

**CRITICAL: Once MCP onboarding is complete (at least one MCP connected),
proceed directly to Phase 2. Do NOT wait for the user to say "done."
The transition must be automatic.**

---

## Zero-MCP flow

If all MCP servers fail in Phase 1, the agent walks through connecting
Slack first (highest immediate value), then Google Workspace using
the onboarding flow above. URLs and setup steps are listed above.
