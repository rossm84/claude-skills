---
name: khoros-liql-reference
description: Use when building or modifying Khoros Community API integrations. Use when writing LiQL queries, debugging Khoros authentication, handling Khoros API errors, or working with community-export-api main.py. Use when encountering 502s, rate limits, or missing author data from Khoros.
---

# Khoros LiQL Reference

## Overview

LiQL (Lithium Query Language) is the query language for Khoros Community APIs. SQL-like syntax for querying messages, users, boards, and nodes.

## Authentication

### Login Flow

```python
# 1. POST to login endpoint
login_url = f"{KHOROS_URL}/restapi/vc/authentication/sessions/login/"
params = {
    "user.login": username,
    "user.password": password,
    "restapi.response_format": "json"
}
resp = requests.post(login_url, data=params, timeout=30)

# 2. Extract session key
session_key = resp.json()["response"]["value"]["$"]

# 3. Set on session (both cookie AND header)
session.cookies.set("LiSESSIONID", session_key)
session.headers["li-api-session-key"] = session_key
```

### Session Caching

Cache session keys for 30 minutes. Re-authenticate when expired.

## Executing LiQL Queries

```python
url = f"{KHOROS_URL}/api/2.0/search"
response = session.get(url, params={"q": liql_query}, timeout=60)
items = response.json().get("data", {}).get("items", [])
```

Response path: `data.data.items[]`

## LiQL Query Patterns

### Fetch Threads

```sql
SELECT id, subject, author.login, author.roles, post_time, body,
       view_href, conversation.last_post_time,
       conversation.messages_count, conversation.solved,
       metrics, kudos.sum(weight)
FROM messages
WHERE board.id = 'board_name' AND depth = 0
ORDER BY post_time DESC
LIMIT 100 OFFSET 0
```

### Fetch Replies for a Thread

```sql
SELECT id, author.login, author.roles, post_time, body, depth, kudos
FROM messages
WHERE topic.id = '{thread_id}' AND depth > 0
ORDER BY post_time ASC
LIMIT 1000
```

Use `topic.id` (NOT `parent.id`) to get all replies in a thread.

### Search Posts

```sql
SELECT id, subject, post_time, author.login, board.id, board.title,
       view_href, body, depth, conversation.messages_count,
       conversation.style, conversation.solved
FROM messages
WHERE subject MATCHES 'keyword' OR body MATCHES 'keyword'
ORDER BY post_time DESC
LIMIT 1000
```

### Get Boards

```sql
SELECT id, title, view_href, parent.id, parent.title
FROM nodes WHERE node_type='board' LIMIT 500
```

### Get Categories

```sql
SELECT id, title FROM nodes WHERE node_type='category' LIMIT 100
```

### Batch by ID

```sql
SELECT id, metrics FROM messages WHERE id IN ('id1','id2','id3')
```

Chunk in batches of 25 to avoid timeouts.

### Kudos Count

```sql
SELECT * FROM kudos WHERE message.id = '{message_id}'
```

## Escaping

Always escape values embedded in LiQL:

```python
def escape_liql(value):
    if not value:
        return ""
    return str(value).replace("\\", "\\\\").replace("'", "\\'")
```

## WHERE Clause Operators

| Operator | Example | Notes |
|----------|---------|-------|
| `=` | `board.id = 'ideas_live'` | Exact match |
| `>`, `<` | `depth > 0` | Numeric comparison |
| `MATCHES` | `subject MATCHES 'crash'` | Full-text search |
| `IN` | `id IN ('1','2','3')` | Set membership, chunk by 25 |
| `AND`, `OR` | Standard boolean | Combine clauses |

## Field Reference

| Field | Type | Notes |
|-------|------|-------|
| `author.login` | string | **Always use this, not just `author`** |
| `author.roles` | object | Role data for staff detection |
| `board.id` | string | Board identifier |
| `board.parent.id` | string | Parent category ID |
| `conversation.style` | string | `"forum"` or `"idea"` |
| `conversation.solved` | bool | Has accepted solution |
| `conversation.messages_count` | int | Total messages in thread |
| `depth` | int | 0 = root thread, >0 = reply |
| `topic.id` | string | Root thread ID (on replies) |
| `metrics.views` | int or dict | Can be `123` OR `{"count": 123}` |
| `kudos.sum(weight)` | aggregation | Inline kudos sum |

## Known Bugs & Gotchas

### author.login vs author (CRITICAL)

`SELECT author, author.roles` causes Khoros to **strip the `login` field** from author objects. Always select `author.login` explicitly:

```sql
-- BAD: author.login will be missing
SELECT author, author.roles FROM messages ...

-- GOOD: author.login preserved
SELECT author.login, author.roles FROM messages ...
```

### Multi-word MATCHES causes 502

Khoros returns 502 Bad Gateway on multi-word MATCHES queries. Split into single words with OR:

```sql
-- BAD: 502 error
WHERE subject MATCHES 'playlist shuffle'

-- GOOD: split into OR
WHERE (subject MATCHES 'playlist' OR subject MATCHES 'shuffle')
```

### Apostrophes break queries

Strip apostrophes from search values before embedding in LiQL.

### metrics.views is polymorphic

```python
views = item.get("metrics", {}).get("views", 0)
if isinstance(views, dict):
    views = views.get("count", 0)
```

### Rate Limiting (429)

```python
if response.status_code == 429:
    retry_after = int(response.headers.get("Retry-After", 30))
    time.sleep(retry_after)
    # Retry once
```

### Search Fallback Strategy

Three-tier fallback for search queries:
1. Try `subject MATCHES + body MATCHES`
2. If 400 error: fall back to `subject MATCHES` only
3. If still fails with enhanced terms: fall back to original single term

## Role Detection

Khoros role data comes in two formats — handle both:

```python
def extract_roles(author_obj):
    roles_data = author_obj.get("roles", {})
    role_list = roles_data.get("role", [])
    if isinstance(role_list, dict):
        role_list = [role_list]  # Single role → wrap in list
    return {r.get("name", "").lower() for r in role_list}
```

## Retry Configuration

```python
from urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter

retry = Retry(total=3, backoff_factor=1,
              status_forcelist=[500, 502, 503, 504])
session.mount("https://", HTTPAdapter(max_retries=retry))
```
