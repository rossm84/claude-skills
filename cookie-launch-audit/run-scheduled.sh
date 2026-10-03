#!/bin/bash
# Scheduled read-only cookie launch audit (cron). Output: ~/notes/cookie-audit-*.md and a run log.
export PATH="$HOME/.nvm/versions/node/v24.13.0/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin"
export HOME="$HOME"
LOG="$HOME/notes/cookie-audit-run-$(date +%Y-%m-%d-%H%M).log"
cd "$HOME" || exit 1
DENY='mcp__claude_ai_Slack_MCP__slack_send_message mcp__claude_ai_Slack_MCP__slack_send_message_draft mcp__claude_ai_Slack_MCP__slack_schedule_message mcp__claude_ai_Slack_MCP__slack_create_canvas mcp__claude_ai_Slack_MCP__slack_update_canvas mcp__plugin_enterprise-search_slack__slack_send_message mcp__plugin_enterprise-search_slack__slack_send_message_draft mcp__plugin_enterprise-search_slack__slack_schedule_message mcp__plugin_enterprise-search_slack__slack_add_reaction mcp__claude_ai_Atlassian_MCP__addOrEditJiraIssueComment mcp__claude_ai_Atlassian_MCP__editJiraIssue mcp__claude_ai_Atlassian_MCP__transitionJiraIssue mcp__claude_ai_Atlassian_MCP__createJiraIssue mcp__claude_ai_Atlassian_MCP__executeWrite mcp__claude_ai_Atlassian_MCP__executeDestructive mcp__claude_ai_Coda_MCP__table_rows_manage mcp__claude_ai_Coda_MCP__content_modify mcp__claude-board__board_post mcp__claude-board__board_reply mcp__claude-board__board_dm_send'
claude -p "Run the cookie-launch-audit skill (~/.claude/skills/cookie-launch-audit/SKILL.md) now. Follow it exactly. It is READ-ONLY: do not send, post, draft, edit or comment anything anywhere, and do not call Google Workspace tools that send, draft, create or update (gmail.send/create_draft, gdocs/gsheets update or create, gcal changes). Only write the report file in ~/notes/." \
  --dangerously-skip-permissions \
  --disallowedTools $DENY \
  --max-turns 150 > "$LOG" 2>&1
