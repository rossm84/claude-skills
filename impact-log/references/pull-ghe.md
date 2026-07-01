# `/impact-log add --from ghe` — Full Reference

> Pull your own GHE PRs from the configured period and surface them as candidate entries to log. Consent-isolated to PRs where you played one of three roles: author, reviewer, or commenter. See the [routing layer](../SKILL.md) for navigation.

---

## When to use

You've shipped, reviewed, or contributed to enough PRs in the period that hand-logging each one would miss things. The pull surfaces candidates; you decide which to keep.

If you log every win the moment it ships, this is redundant. The pull matters most for catch-up — coming back to the log after a few weeks, or running before quarterly review.

## Why opt-in

Per [`docs/privacy-ethics.md`](../../../../../docs/privacy-ethics.md), this skill never silently scrapes GHE. The pull runs only when you explicitly invoke `add --from ghe`, and it queries only PRs **you** authored, reviewed, or commented on. It never reads PRs from teammates' activity where you played no role.

## Layering with `/sync-prs`

PRs that have already been merged and synced to Jira via [`/sync-prs`](../../../../pr-jira-sync/skills/sync-prs/SKILL.md) (PR merged → Jira comment) carry the cross-system link the pull uses to map evidence to outcome. Run `/sync-prs` first if it hasn't been run recently — the pull prompts you when the most recent sync is older than the configured period.

## Workflow

1. **Determine the period.** Default: last 30 days. Override with `--period <N>d` or `--since <YYYY-MM-DD>`.
2. **Query GHE for the IC's contributions.** Use `gh` CLI when available (preferred for local auth) or fall back to the `ghe` MCP server. Three role-specific queries:

   | Role | `gh search` flag | Meaning |
   |---|---|---|
   | Author | `--author=@me` | PRs you opened |
   | Reviewer | `--reviewed-by=@me` | PRs you formally reviewed |
   | Commenter | `--commenter=@me` | PRs that received your comments (including inline review comments) |

   Combine with `--updated=">${PERIOD_START}"` (or `--merged-at` if you want to scope to merged-only).

3. **Dedupe.** A PR may surface in multiple roles. Collapse to one row per PR with the union of roles.
4. **Surface candidates.** For each PR, present:

   | Field | Source |
   |---|---|
   | Title | `gh` PR title |
   | URL | PR URL |
   | Date | Last-updated timestamp |
   | Role(s) | Author / Reviewer / Commenter (whichever applied) |
   | Linked Jira ticket(s) | If `/sync-prs` has run, the Jira ticket key(s) referenced in the PR description or comments |

5. **User reviews and selectively logs.** For each candidate, the IC chooses:
   - **Add** — fold into the impact log as a new entry (the skill prompts for Pillar / Sub-area / Outcome / AI accountability)
   - **Skip** — don't log (e.g., trivial PRs, test fixtures, PRs that don't represent meaningful work)
   - **Defer** — flag for later consideration; the candidate stays in a holding list until the next pull

6. **Health check.** If the pull returned zero candidates, suggest the user verify: (a) the period covers actual work, (b) `gh` auth is current, (c) `/sync-prs` has run if the IC works against tickets.

## Example queries

```bash
# Last 30 days, all roles
gh search prs --author=@me --updated=">$(date -v-30d +%Y-%m-%d)"
gh search prs --reviewed-by=@me --updated=">$(date -v-30d +%Y-%m-%d)"
gh search prs --commenter=@me --updated=">$(date -v-30d +%Y-%m-%d)"

# Quarter scope (since beginning of Q1 2026)
gh search prs --author=@me --updated=">2026-01-01"

# Merged-only
gh search prs --author=@me --merged-at=">$(date -v-30d +%Y-%m-%d)"
```

## Output format

Candidate entries are surfaced as a Markdown table. Example:

```markdown
| # | PR | Title | Role | Date | Linked Jira |
|---|----|-------|------|------|-------------|
| 1 | personalization/foo#123 | Add candidate filter for blocked artists | Author | 2026-04-29 | TUN-1234 |
| 2 | personalization/bar#45 | Refactor scoring to remove dead code | Author, Reviewer | 2026-04-22 | — |
| 3 | shared/library#789 | Fix memory leak in worker pool | Commenter | 2026-04-15 | INFRA-987 |
```

Per row, the IC types `add 1`, `skip 2`, `defer 3` (or similar shorthand) until the list is exhausted.

## Privacy considerations

- **Only your own contributions.** The pull does not query teammates' PRs.
- **No silent persistence.** Candidates are presented in-session; only entries you add are written to the log.
- **GHE token scope.** `gh` reads PRs you are authorized to see. The pull does not bypass GHE's access controls.

## Related references

- [`schedule.md`](schedule.md) — install a recurring pull via cron / launchd (with `--subcommand "add --from ghe"`)
- [`template-impact-log.md`](template-impact-log.md) — the entry shape the pull produces
- [`/sync-prs`](../../../../pr-jira-sync/skills/sync-prs/SKILL.md) — the tracking-sync layer that populates Jira ticket links the pull uses
