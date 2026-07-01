# `gather` — Weekly Contribution Gathering

Weekly accumulation of contributions from MCP sources. `gather` is the only subcommand that queries external systems — `synthesize` and `compile` only reshape data that `gather` already collected.

## When to use

Run at the start of each week (or biweekly) to capture the previous period's contributions. The gathered block is appended to the monthly contributions file (`~/.impact-log/contributions/YYYY-MM.md` or `.impact-log/contributions/YYYY-MM.md`).

If the monthly file does not exist, create it with:

```markdown
# YYYY-MM Contributions

**Status:** Accumulating (weekly blocks below, pending monthly synthesis)
```

## 8-Step Gathering Checklist

Each step queries one MCP source. Every step must be *attempted* — the completeness self-check (Step 8) rejects blocks where a step was skipped without explanation. When a source is unavailable, record the failure explicitly and continue.

Valid empty-section values:
- "No data for this period" (tool was called, returned empty)
- "MCP auth error — [tool] requires reauthentication" (tool called, auth failed)
- "[Tool] returned 0 results ([specific reason])" (tool called, known issue)

The value "Not queried this week" is **rejected** — it means a step was skipped.

### Step 1: GHE Pull Requests (authored)

**Tool:** GHE MCP `search_prs_by_date`
**Parameters:** author from config `ghe_username`, date range for the past week, state "merged"
**Record:** title, repo, URL, merge date

**On failure:** Note "GHE data unavailable this week" and continue.

### Step 1b: GHE Pull Requests (reviewed)

**Tool:** GHE MCP `search_prs_by_date`
**Parameters:** reviewer from config `ghe_username`, same date range
**Record:** title, repo, URL, review date

### Step 2: Jira Tickets

**Tool:** `atlassian-mcp` `search_issues_advanced`
**JQL:** `(assignee = currentUser() OR reporter = currentUser() OR commenter = currentUser()) AND updated >= -7d AND project in (<configured_projects>)`

**Critical:** The `project in (...)` filter is required — `currentUser()` alone returns 0 results from the Atlassian MCP without a project scope. An empty result looks like "no tickets" but is actually a query failure. The project list comes from config `jira_projects` (e.g., `TUN, SESH`). If not configured, prompt the user to set it before running.

**EM extension (when `--level em/sem/director` is configured):** Run the additional EM-specific queries defined in [`pull-jira.md`](pull-jira.md) § EM queries (epic owner, initiative watcher) adapted to the weekly `-7d` window.

**JIRA stale index fallback protocol:** If date-bounded queries return 0 results unexpectedly, apply the 4-tier fallback in [`jira-fallback.md`](jira-fallback.md).

**On failure:** Note "Jira data unavailable" with the specific error and continue.

### Step 2b: Pair/Mob Contributions (optional, Senior+/EM)

For levels where enabling-others is a key differentiator (Senior, Staff, EM, Senior EM, Director), run the pair/mob query defined in [`pull-jira.md`](pull-jira.md) § EM queries adapted to the weekly `-7d` window. See [`jira-fallback.md`](jira-fallback.md) for the portability note on the Pair/Mob custom field.

**On failure or if field not available:** Skip gracefully — this step is optional.

### Step 3: Google Docs

**Tool:** `google-drive-mcp` `list_drive_files`
**Query:** files modified in the past week, owned by or shared with the user
**Record:** doc title, URL, last modified date

**On failure:** Note "Google Drive data unavailable" and continue.

### Step 4: Git Activity

**Tool:** Local git CLI
**Command:** `git log --author="<username>" --since="7 days ago" --oneline` across configured repos
**Record:** commit count, repos touched, notable commit messages

**Optional: Knowledge-artifact captures.** Commits that create or update documentation, runbooks, skills, or onboarding materials are Culture & Organization evidence that PRs-merged alone misses. When scanning git history, flag commits whose paths match `docs/`, `skills/`, `runbooks/`, `CLAUDE.md`, `README.md`, or `CONTRIBUTING.md` as potential knowledge-sharing contributions. This is especially valuable for the Culture & Organization pillar, which is often undercaptured.

**On failure:** Note "Git data unavailable" and continue.

### Step 5: Experiments

**Tool:** Oliver MCP `search_experiments`
**Parameters:** squad from config `ep_squad_name`, states ACTIVE and INACTIVE
**Filter:** experiments where the user is a contact

For each experiment found, capture the **outcome**, not just the existence:
- `get_experiment_results` for metric deltas (which metrics moved, by how much, statistical significance)
- `get_experiment_exposures` for user reach (treatment group size, exposure count)
- Ship decision: was it shipped, rolled back, or no-shipped? At what rollout percentage?
- If shipped: what was the business impact? (metric delta × user reach = impact estimate)
- If no-shipped: what was learned? (validated learning is still impact — see [`idt-framework-employee.md`](idt-framework-employee.md) § Framing second-order impact)

The ship signal — "we shipped to N% because metric X moved by Y" — is often the single strongest evidence in the entire weekly block.

**On failure:** Note "Oliver experiment data unavailable" and continue.

### Step 6: Business Context Enrichment

**Tool:** Groove MCP `list-epics` for the current period
**Enrich:** For each Jira ticket or PR from Steps 1-2, check if it maps to a Groove DOD or initiative via `get-work-item-context` → `get-initiative`

**Tool:** Oliver MCP `get_component_metadata`, `get_service_dependencies` for context on systems the user works on

**Tool (optional):** Lineage MCP `get_summary`, `analyze_usage` for downstream blast radius — how many teams, users, and dashboards consume the data or services the user works on. For data/pipeline ICs, this is often the most compelling quantitative signal: "built a pipeline consumed by N teams powering M dashboards."

**On failure:** Note "Business context enrichment unavailable" and continue. Lineage is optional — skip gracefully if not configured.

### Step 7: Slack Activity

**Tool:** Slack MCP `slack_search_public_and_private`
**Queries:**
- Recognition and praise threads mentioning the user
- Cross-team coordination threads the user participated in
- For EMs: recognition threads about team members (team-level aggregate only — do not surface individual messages)

**Configured channels:** From config `slack_review_channels` (default: team-specific channels)

**On failure:** Note "Slack data unavailable" and continue.

### Step 8: Completeness Self-Check

Verify the weekly block contains all section headers:

```
### PRs Authored
### PRs Reviewed
### Jira Tickets
### Pair/Mob Contributions (optional, Senior+/EM)
### Google Docs
### Git Activity
### Experiments
### Business Context
### Slack Activity
```

Every header must be present. Every section must have content (even if that content is a failure note). Blocks missing headers are flagged for the user to review before appending to the monthly file.

### Pillar Gap Check (inline)

After gathering, check which pillars (Business Impact, Technical Excellence, Culture & Organization) have coverage from this week's entries. Surface gaps:

> "This week's entries cover Technical Excellence and Business Impact. No entries for Culture & Organization — is there mentoring, coaching, or team-building work to capture?"

## Level-Weighted Source Priority

When a career level is configured, `gather` uses the same source weighting as `prep` discovery mode (see [`prep-interactive-flow.md`](prep-interactive-flow.md)):

- **Eng I/II:** GHE (authored PRs) and Jira (assigned tickets) are primary
- **Senior+:** GHE (reviews given), Oliver (experiments, SLOs), Groove (DOD alignment) are weighted higher
- **EM:** Google Drive (1:1 notes), Slack (team recognition), Groove (team DODs) are weighted higher

## Backfill Protocol

When running `gather` for a period older than the current week (catching up after time off):

1. Run each step with the appropriate date range
2. Note "Backfill for week of YYYY-MM-DD" in the block header
3. Completeness self-check still applies — every step must be attempted even for backfill periods
4. Pillar gap check still runs but findings are informational (harder to act on gaps from past weeks)

## Output Format

Each weekly block is appended to the monthly contributions file:

```markdown
## Week of YYYY-MM-DD

### PRs Authored
- [PR title](url) — repo, merged YYYY-MM-DD

### PRs Reviewed
- [PR title](url) — repo, reviewed YYYY-MM-DD

### Jira Tickets
- [TICKET-123](url) — summary, status, role (assignee/reporter/commenter)

### Google Docs
- [Doc title](url) — last modified YYYY-MM-DD

### Git Activity
- N commits across M repos

### Experiments
- [Experiment name](EP link) — status, metric delta, exposure count

### Business Context
- [DOD/Initiative](Groove link) — alignment context

### Slack Activity
- Recognition threads, coordination threads (summarized, not quoted)
```

## Privacy

- Queries only the invoking user's own contributions (same consent model as `add --from ghe/jira`)
- Slack search respects the user's own access scope
- For EMs: team member recognition threads are surfaced as aggregate patterns only — individual messages are not quoted or attributed
- Each step requires explicit invocation — nothing runs automatically without consent
- The `schedule install` subcommand can register a recurring `gather` via cron/launchd, but the user must install it explicitly
