---
name: python-retry-resilience
description: Use when making HTTP requests that need retry logic, exponential backoff, or rate limit handling. Use when building Python API clients, dealing with 429 Too Many Requests, 502 Bad Gateway, or transient server errors. Use when configuring requests.Session with retries.
---

# Python Retry & Resilience Patterns

## Overview

Use `urllib3.util.retry.Retry` with `requests.HTTPAdapter` for automatic retries. Handle rate limits (429) manually. Don't write ad-hoc retry loops.

## Session with Automatic Retries

```python
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
import requests

def create_resilient_session():
    session = requests.Session()
    retry = Retry(
        total=3,                                    # Max retry attempts
        backoff_factor=1.0,                         # Wait 1s, 2s, 4s between retries
        status_forcelist=[500, 502, 503, 504],      # Retry on server errors
        allowed_methods=["GET", "POST"],            # Which methods to retry
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount("http://", adapter)
    session.mount("https://", adapter)
    session.headers.update({
        "User-Agent": "MyApp/1.0",
        "Accept": "application/json",
    })
    return session
```

**Use it everywhere:**
```python
session = create_resilient_session()
resp = session.get("https://api.example.com/data", timeout=30)
```

## Rate Limit Handling (429)

`Retry` doesn't handle 429 well by default. Handle it manually:

```python
def request_with_rate_limit(session, method, url, **kwargs):
    kwargs.setdefault("timeout", 60)
    resp = session.request(method, url, **kwargs)
    if resp.status_code == 429:
        retry_after = int(resp.headers.get("Retry-After", 30))
        time.sleep(retry_after)
        resp = session.request(method, url, **kwargs)
    resp.raise_for_status()
    return resp
```

## Quick Reference

| `Retry` Parameter | What It Does | Recommended |
|-------------------|--------------|-------------|
| `total` | Max retries | 3 |
| `backoff_factor` | Delay multiplier (1.0 = 1s, 2s, 4s) | 1.0 |
| `status_forcelist` | HTTP codes to retry on | `[500, 502, 503, 504]` |
| `allowed_methods` | Methods safe to retry | `["GET", "POST"]` for idempotent APIs |
| `raise_on_status` | Raise after final retry | `True` (default) |

## Backoff Timing

With `backoff_factor=1.0`:

| Retry # | Wait Time |
|---------|-----------|
| 1st | 1 second |
| 2nd | 2 seconds |
| 3rd | 4 seconds |

Formula: `backoff_factor * (2 ** (retry - 1))`

## Always Set Timeouts

```python
# Connection + read timeout
resp = session.get(url, timeout=30)

# Separate timeouts: (connect, read)
resp = session.get(url, timeout=(5, 30))
```

**Never omit timeout.** Without it, requests can hang forever.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Writing manual retry loops | Use `Retry` + `HTTPAdapter` — it's built-in |
| Retrying POST blindly | Only retry POST if your API is idempotent |
| Adding 429 to `status_forcelist` | Handle 429 manually — need to read `Retry-After` header |
| No timeout | Always pass `timeout=` — requests hangs forever otherwise |
| Retrying on 400/401/403 | These are client errors — retrying won't help |
| `backoff_factor=0` | No backoff = hammering the server. Use `1.0` minimum |
| Creating new session per request | Create once, reuse — sessions pool TCP connections |
