---
name: khoros-community-search
description: Use when the user wants to search the Spotify Community, find threads, check board activity, analyze community sentiment, or pull data from Khoros. Use when user mentions community posts, threads, boards, or community topics. No setup required — uses deployed API.
---

# Querying the Spotify Community

## Overview

Search the Spotify Community (Khoros-powered) via the deployed API at `community-export-dot-spotify-community.appspot.com`. No auth tokens or setup needed — the backend handles Khoros authentication.

## API Base URL

```
https://community-export-dot-spotify-community.appspot.com
```

## Available Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/export` | POST | Search threads/posts with filters |
| `/api/boards` | GET | List all boards (inc. hidden) |
| `/api/thread/{id}` | GET | Full thread with replies + AI analysis |
| `/api/s4d-insights` | GET | S4D board insights (precomputed daily) |
| `/api/health` | GET | Health check |

## Search Posts (`POST /api/export`)

```json
{
  "boardId": "all",
  "postType": "threads",
  "searchTerm": "playlist",
  "searchMode": "any",
  "limit": 100
}
```

### Parameters

| Field | Type | Values | Default |
|-------|------|--------|---------|
| `boardId` | string | `"all"`, board ID, or `"category:cat_id"` | `"all"` |
| `postType` | string | `"all"`, `"threads"`, `"ideas"`, `"replies"` | `"all"` |
| `searchTerm` | string | **Single word only** (see gotchas) | `""` |
| `searchMode` | string | `"any"`, `"all"`, `"exact"` | `"any"` |
| `enhanceSearch` | bool | AI-expand search terms with synonyms | `false` |
| `dateFrom` | string | `"YYYY-MM-DD"` | none |
| `dateTo` | string | `"YYYY-MM-DD"` | none |
| `filters` | object | Quick filters (see below) | `{}` |
| `limit` | int | 1–5000 | 1000 |

### Quick Filters

```json
{
  "filters": {
    "unsolved": true,
    "hasReplies": true,
    "noReplies": true,
    "ideasOnly": true
  }
}
```

### Response Shape

```json
{
  "success": true,
  "count": 42,
  "posts": [
    {
      "id": "12345",
      "subject": "Playlist shuffle broken",
      "author": "username",
      "post_time": "2026-03-01T10:00:00Z",
      "board_id": "ongoing-issues",
      "board_name": "Ongoing Issues",
      "url": "https://community.spotify.com/t5/...",
      "type": "forum",
      "depth": 0,
      "reply_count": 15,
      "body": "Text content...",
      "views": 5000,
      "trending_score": 7.2,
      "daily_views": 300
    }
  ]
}
```

## Get Thread Detail (`GET /api/thread/{id}`)

Returns full thread with replies, stats, and AI analysis.

```
GET /api/thread/5923810
```

Response includes: `thread`, `replies`, `stats` (views, kudos, reply_count), `sentiment`, `summary`.

## List Boards (`GET /api/boards`)

Returns all boards organized by category.

```
GET /api/boards
```

Response includes: `boards` (flat list), `categories` (tree structure with nested boards).

## Common Board IDs

| Board | ID | Notes |
|-------|----|-------|
| Ongoing Issues | `ongoing-issues` | Active bug reports |
| Ideas | `ideas_live` | Feature requests |
| Spotify Developer | `Spotify_Developer` | S4D board |
| Android | `Android` | Android-specific |
| iOS | `iOS-iPhone-iPad` | iOS-specific |
| Desktop | `Desktop-Windows` / `Desktop-Linux` / `Desktop-Mac` | Per-platform |

Use `/api/boards` to get the complete current list.

## CRITICAL Gotchas

### Single-word searches only
Multi-word search terms cause 502 errors from Khoros. **Always use single words.**

```json
{"searchTerm": "playlist"}
{"searchTerm": "shuffle"}
```

NOT: `{"searchTerm": "playlist shuffle"}`

To search for a concept that needs multiple words, either:
- Set `"enhanceSearch": true` (AI expands to synonym list)
- Make multiple single-word searches and combine results

### No apostrophes
Apostrophes in search terms break queries. Strip them before searching.

### Hidden/internal boards
Some boards are internal (Backstage, Closed Escalations, Deleted Posts). When building reports, filter these out of results.

### Staff vs. community users
Known staff usernames: `lambertspot`, `thepodfather`, `novy`, `katya_spotify`, `sebas_spotify`, `peter_spotify`, `spotify_moderator`, `spotifymoderator`. **joaoaranha is NOT staff.**

## Example: Quick Community Pulse

```bash
# Top recent threads about AI
curl -X POST https://community-export-dot-spotify-community.appspot.com/api/export \
  -H "Content-Type: application/json" \
  -d '{"searchTerm":"AI","postType":"threads","limit":50}'

# Unsolved threads in last 7 days
curl -X POST https://community-export-dot-spotify-community.appspot.com/api/export \
  -H "Content-Type: application/json" \
  -d '{"postType":"threads","dateFrom":"2026-03-03","filters":{"unsolved":true},"limit":100}'
```
