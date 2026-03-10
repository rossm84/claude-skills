---
name: coda-readonly-integration
description: Use when fetching structured data from Coda tables via the API for display or processing in another app — release management, project tracking, content catalogs — without writing back to Coda
---

# Read-Only Coda Table Integration

## Overview

Fetch rows from a Coda table via the REST API, transform them into a usable format, and cache for performance. Coda is the source of truth — your app reads but never writes back.

## Quick Reference

| Operation | Endpoint |
|-----------|----------|
| List rows | `GET /docs/{docId}/tables/{tableId}/rows?useColumnNames=true` |
| Single row | `GET /docs/{docId}/tables/{tableId}/rows/{rowId}` |
| List tables | `GET /docs/{docId}/tables` |
| Search rows | `GET /docs/{docId}/tables/{tableId}/rows?query=...` |

**Base URL:** `https://coda.io/apis/v1`

**Auth:** `Authorization: Bearer {CODA_API_TOKEN}`

## Implementation

```python
import requests

CODA_API = "https://coda.io/apis/v1"
CODA_TOKEN = os.environ.get('CODA_API_TOKEN')
CODA_DOC_ID = "YOUR_DOC_ID"      # From the Coda URL: coda.io/d/DocName_d{DOC_ID}
CODA_TABLE_ID = "YOUR_TABLE_ID"  # From table URL or API

def fetch_coda_rows(doc_id=CODA_DOC_ID, table_id=CODA_TABLE_ID):
    """Fetch all rows from a Coda table with pagination."""
    headers = {'Authorization': f'Bearer {CODA_TOKEN}'}
    rows = []
    page_token = None

    while True:
        params = {'useColumnNames': 'true', 'limit': 200}
        if page_token:
            params['pageToken'] = page_token

        resp = requests.get(
            f'{CODA_API}/docs/{doc_id}/tables/{table_id}/rows',
            headers=headers, params=params
        )
        resp.raise_for_status()
        data = resp.json()

        for item in data.get('items', []):
            row = {'id': item['id'], 'name': item.get('name', '')}
            vals = item.get('values', {})
            # Map Coda column names to your field names
            row['title'] = vals.get('Project Title', '')
            row['date'] = vals.get('Expected Date', '')
            row['status'] = vals.get('Status', '')
            # ... map more fields as needed
            rows.append(row)

        page_token = data.get('nextPageToken')
        if not page_token:
            break

    return rows
```

## Coda Value Types

| Coda Type | Python Value |
|-----------|-------------|
| Text | `str` |
| Date | `str` (ISO format) |
| Number | `int` or `float` |
| Checkbox | `bool` |
| People | `str` (email) or `list` |
| Relation | `list` of row references |
| Rich text | `str` (HTML) — strip with `re.sub(r'<[^>]+>', '', val)` |
| Select list | `str` (single) or `list` (multi) |

## Fallback Token Pattern

Coda tokens have rate limits and can expire. Use a fallback:

```python
CODA_TOKEN = os.environ.get('CODA_API_TOKEN')
CODA_TOKEN_FALLBACK = os.environ.get('CODA_API_TOKEN_FALLBACK')

def _coda_request(url, params):
    headers = {'Authorization': f'Bearer {CODA_TOKEN}'}
    resp = requests.get(url, headers=headers, params=params)
    if resp.status_code in (401, 429) and CODA_TOKEN_FALLBACK:
        headers = {'Authorization': f'Bearer {CODA_TOKEN_FALLBACK}'}
        resp = requests.get(url, headers=headers, params=params)
    resp.raise_for_status()
    return resp.json()
```

## Caching

Coda data rarely changes in real-time. Cache with a TTL:

```python
_coda_cache = {}
_coda_cache_time = {}
CODA_CACHE_TTL = 300  # 5 minutes

def fetch_coda_cached(table_id):
    import time
    now = time.time()
    if table_id in _coda_cache and (now - _coda_cache_time.get(table_id, 0)) < CODA_CACHE_TTL:
        return _coda_cache[table_id]
    rows = fetch_coda_rows(table_id=table_id)
    _coda_cache[table_id] = rows
    _coda_cache_time[table_id] = now
    return rows
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Forgetting `useColumnNames=true` | Without it, values are keyed by column ID (`c-ABC123`), not human-readable names. |
| Not paginating | Default limit is 200 rows. Tables with more need `nextPageToken` loop. |
| Writing back to Coda | If Coda is source of truth, don't create update endpoints. Confusion about which system "owns" the data causes sync bugs. |
| Hardcoding column names | Coda users rename columns. Map them in one place so you only fix one spot. |
| Not handling rich text | Coda rich text fields return HTML. Strip tags if you need plain text. |
| Rate limit: 100 req/min | Coda enforces per-token rate limits. Use caching + fallback token for high-traffic apps. |

## Finding IDs

- **Doc ID**: From URL `coda.io/d/DocName_d{DOC_ID}` — the part after `_d`
- **Table ID**: Call `GET /docs/{docId}/tables` to list all, or find in the table URL
- **Row ID**: Each row has an `id` field in the API response (format: `i-XXXXXXXX`)
