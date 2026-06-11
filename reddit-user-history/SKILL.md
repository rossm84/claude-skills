---
name: reddit-user-history
description: Use when extracting a Reddit user's post and comment history. Use when the user asks to pull, scrape, export, or analyze Reddit activity for a specific username. Uses Arctic Shift API (free, no auth). Outputs CSV and Google Sheet.
---

# Reddit User History Extraction

Extract any Reddit user's full post and comment history via the Arctic Shift API. Free, no auth, no rate limits.

## API

**Base:** `https://arctic-shift.photon-reddit.com/api`

| Endpoint | Purpose |
|----------|---------|
| `/posts/search?author={user}&limit=100&sort=desc` | User's submissions |
| `/comments/search?author={user}&limit=100&sort=desc` | User's comments |

**Pagination:** Add `&before={last_created_utc}` to get the next page. Stop when response returns empty `data` array or fewer than `limit` items.

**Response format:** JSON with `data` array. Each item has `created_utc`, `subreddit`, `permalink`, `body` (comments) or `title`/`selftext` (posts).

## Usage

Run the extraction script in this directory:

```bash
python3 ~/.claude/skills/reddit-user-history/extract.py USERNAME
```

This outputs `/tmp/reddit_{username}_history.csv`. Then:

1. Copy CSV to Desktop: `cp /tmp/reddit_{username}_history.csv "/mnt/c/Users/RossMiller/Desktop/"`
2. Create Google Sheet with sample rows via `create_google_sheet` MCP tool
3. Tell user to import full CSV via File > Import in the sheet

## Google Sheet size limits

The `create_google_sheet` MCP tool can handle ~50 rows inline. For larger datasets (common - active users have 1000+ comments), always save the full CSV and create a sample sheet with import instructions.

## Other useful endpoints

| Endpoint | Purpose |
|----------|---------|
| `/api/users/interactions/subreddits?author={user}` | Per-subreddit activity breakdown |
| `/api/posts/search?subreddit={sub}&limit=100` | Posts in a specific subreddit |

## Notes

- Arctic Shift data is current through ~April 2026 with ongoing updates
- Reddit's own API requires OAuth + registered app + 2-4 week approval. Don't bother.
- Pushshift is dead for public use. PullPush.io works but data only through May 2025.
- The download tool at `arctic-shift.photon-reddit.com/download-tool` also works in-browser.
