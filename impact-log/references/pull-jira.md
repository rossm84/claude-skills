# `/impact-log add --from jira` — Full Reference

> Pull your own Jira contributions from the configured period and surface them as candidate entries to log. Consent-isolated to tickets where you played one of three roles: assignee, reporter, or commenter. See the [routing layer](../SKILL.md) for navigation.

---

## When to use

You've assigned, reported, or moved meaningful Jira work in the period and want to capture it in the impact log without re-typing each ticket.

If you log every win the moment a ticket closes, this is redundant. The pull matters most for catch-up — coming back to the log after a few weeks, or running before quarterly review.

## Why opt-in

Per [`docs/privacy-ethics.md`](../../../../../docs/privacy-ethics.md), this skill never silently scrapes Jira. The pull runs only when you explicitly invoke `add --from jira`, and it queries only tickets **you** assigned, reported, or commented on. It never reads tickets from teammates' activity where you played no role.

## Layering with `/groove-sync` and `/sync-prs`

Two adjacent tracking layers populate the cross-system links the pull uses:

| Layer | Direction | What it adds |
|---|---|---|
| [`/groove-sync`](../../../../groove-epic-sync/skills/groove-sync/SKILL.md) | Groove DOD → Jira epic | Strategic-alignment context (which DOD an epic implements) |
| [`/sync-prs`](../../../../pr-jira-sync/skills/sync-prs/SKILL.md) | PR merged → Jira comment | PR provenance and commit-level context on tickets |

Run either if it hasn't been run recently — the pull prompts you when the most recent sync is older than the configured period.

## Workflow

1. **Determine the period.** Default: last 30 days. Override with `--period <N>d` or `--since <YYYY-MM-DD>`.
2. **Query Jira for the user's contributions.** Use `acli` (Atlassian CLI) when available (preferred for local auth) or fall back to the `atlassian-mcp` MCP server.

   **IC queries (default):**

   | Role | JQL clause | Meaning |
   |---|---|---|
   | Assignee | `assignee = currentUser()` | Tickets assigned to you |
   | Reporter | `reporter = currentUser()` | Tickets you opened |
   | Commenter | `commenter = currentUser()` | Tickets that received your comments |

   **EM queries (when `--level em/sem/director` is configured):**

   In addition to the IC queries above, run these EM-specific queries to capture leadership-level work that doesn't show up in individual ticket assignment:

   | Role | JQL clause | Meaning |
   |---|---|---|
   | Epic owner | `type = Epic AND assignee = currentUser()` | Epics you own (strategic-level work) |
   | Initiative watcher | `type in (Epic, Story) AND watcher = currentUser() AND status changed AFTER -30d` | Tickets you're watching that moved recently — evidence of oversight and unblocking. Adjust the `-30d` to match the configured period. |
   | Pair/mob contributor | `"Pair/Mob[User Picker (multiple users)]" = currentUser()` | Tickets where you paired or mobbed. The human-readable clause name is portable across Jira projects; the underlying custom field ID (`customfield_11473`) may differ in other Jira instances. |

   EM queries surface the initiative-level view that represents managerial impact — epics owned, work unblocked by watching and intervening, and collaborative contributions. Combined with the standard IC queries, this gives EMs a more complete candidate list.

   Combine all queries with `AND updated >= -30d` (or the chosen period boundary) to scope.

3. **Dedupe.** A ticket may surface in multiple roles. Collapse to one row per ticket with the union of roles.
4. **Surface candidates.** For each ticket, present:

   | Field | Source |
   |---|---|
   | Key | Jira ticket key (e.g., `TUN-1234`) |
   | Summary | Ticket summary line |
   | Status | Current workflow status (To Do / In Progress / Done / etc.) |
   | Date | Last-updated timestamp |
   | Role(s) | Assignee / Reporter / Commenter (whichever applied) |
   | Linked PRs | If `/sync-prs` has run, the PR URL(s) referenced in the ticket comments |
   | Parent / Epic | If `/groove-sync` has run, the parent epic and Groove DOD link |

5. **User reviews and selectively logs.** For each candidate, the IC chooses:
   - **Add** — fold into the impact log as a new entry (the skill prompts for Pillar / Sub-area / Outcome / AI accountability, and pre-fills the Source field with the ticket URL)
   - **Skip** — don't log (e.g., maintenance tickets, low-impact work)
   - **Defer** — flag for later consideration; the candidate stays in a holding list until the next pull

6. **Health check.** If the pull returned zero candidates, suggest the user verify: (a) the period covers actual work, (b) `acli` (or the atlassian-mcp server) is authenticated, (c) the IC's Jira account has activity on the relevant projects in the period.

## Example queries

```bash
# Last 30 days, assigned tickets (acli)
acli jira workitem search --jql "assignee = currentUser() AND updated >= -30d"

# Reporter (you opened the ticket)
acli jira workitem search --jql "reporter = currentUser() AND updated >= -30d"

# Commenter
acli jira workitem search --jql "commenter = currentUser() AND updated >= -30d"

# Quarter scope
acli jira workitem search --jql "assignee = currentUser() AND updated >= '2026/01/01'"

# Done-only (focus on completed work)
acli jira workitem search --jql "assignee = currentUser() AND status = Done AND resolved >= -30d"
```

When `acli` isn't available, the same JQL goes to `mcp__atlassian-mcp__list_tickets` with the `jql_query` parameter.

## Output format

Candidate entries are surfaced as a Markdown table. Example:

```markdown
| # | Key | Summary | Status | Role | Updated | Linked PRs |
|---|-----|---------|--------|------|---------|------------|
| 1 | TUN-1234 | Add candidate filter for blocked artists | Done | Assignee | 2026-04-29 | personalization/foo#123 |
| 2 | TUN-1240 | Investigate scoring regression | In Progress | Reporter | 2026-04-25 | — |
| 3 | INFRA-987 | Fix memory leak in worker pool | Done | Commenter | 2026-04-15 | shared/library#789 |
```

Per row, the IC types `add 1`, `skip 2`, `defer 3` (or similar shorthand) until the list is exhausted.

## Privacy considerations

- **Only your own contributions.** The pull does not query teammates' tickets.
- **No silent persistence.** Candidates are presented in-session; only entries you add are written to the log.
- **Jira project scope.** `acli` and `atlassian-mcp` read tickets you are authorized to see. The pull does not bypass Jira's project-level access controls.
- **Comment content sensitivity.** When surfacing tickets where your role is "commenter," the pull shows the ticket title and metadata only — not the comment text. Reviewing the actual comment is a follow-up step you take manually if desired.

## Related references

- [`schedule.md`](schedule.md) — install a recurring pull via cron / launchd (with `--subcommand "add --from jira"`)
- [`template-impact-log.md`](template-impact-log.md) — the entry shape the pull produces
- [`/groove-sync`](../../../../groove-epic-sync/skills/groove-sync/SKILL.md) — the tracking-sync layer for Groove DOD ↔ Jira epic
- [`/sync-prs`](../../../../pr-jira-sync/skills/sync-prs/SKILL.md) — the tracking-sync layer for PR merged → Jira comment
