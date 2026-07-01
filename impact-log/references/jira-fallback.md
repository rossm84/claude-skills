# JIRA Stale Index Fallback Protocol

The Jira MCP `search_issues_advanced` relies on a search index that periodically goes stale. Date-bounded queries (`updated >= -7d`) may return 0 results for dates past the stale watermark, even with correct project filters. This reference documents the fallback protocol used by `gather` and `add --from jira`.

## Symptom

`updated >= recent_date` returns nothing, but `updated >= older_date` returns tickets with timestamps only up to a stale cutoff point. The search index has not caught up to recent activity.

## 4-Tier Fallback

| Tier | Query modification | Rationale |
|------|-------------------|-----------|
| 1 | `status changed AFTER -7d` | Bypasses the stale date index by querying status transitions instead of update timestamps |
| 2 | `updated >= -14d` | Wider window — the stale watermark may be within the last 7 days but not the last 14 |
| 3 | Status-based query with no date filter, then filter client-side | Removes date dependency entirely; slower but reliable |
| 4 | Direct key lookup for known tickets | If the user knows specific ticket keys, look them up directly |

Each tier is tried in order. If Tier 1 returns results, stop. If not, proceed to Tier 2, and so on.

## When to apply

- `gather` Step 2 (Jira Tickets) — apply automatically when the primary query returns 0 results unexpectedly
- `add --from jira` — apply when the configured period returns fewer results than expected
- `rescue` — apply when sweeping for ephemeral Jira evidence

## User notification

When a fallback tier is used, note it in the output:

> "Jira date index appears stale — used status-based query (Tier 1 fallback). Results may include tickets outside the configured period; verify dates manually."

## Known limitation

The pair/mob query (`"Pair/Mob[User Picker (multiple users)]" = currentUser()`) is not affected by the date index stale issue — it queries a custom field, not a date range. However, it should still be combined with a date filter where possible for performance. The human-readable clause name is portable across Jira projects; the underlying custom field ID (`customfield_11473`) is Spotify Jira-specific and may differ in other instances.
