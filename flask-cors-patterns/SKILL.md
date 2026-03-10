---
name: flask-cors-patterns
description: Use when building Flask APIs that need CORS support. Use when encountering CORS errors, Access-Control-Allow-Origin issues, preflight OPTIONS requests, or cross-origin fetch failures. Use when a frontend on a different domain needs to call a Flask backend.
---

# Flask CORS Patterns

## Overview

Handle CORS with an explicit origin whitelist and a helper function. Don't use wildcard `*` in production. Handle OPTIONS preflight requests in every endpoint.

## Core Pattern

```python
ALLOWED_ORIGINS = [
    'https://myapp.web.app',
    'https://myapp.firebaseapp.com',
    'http://localhost:5000',
    'http://localhost:3000',
]

def get_cors_headers(origin: str) -> dict:
    headers = {
        'Access-Control-Allow-Methods': 'POST, OPTIONS, GET',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        'Access-Control-Max-Age': '3600',
    }
    if origin in ALLOWED_ORIGINS:
        headers['Access-Control-Allow-Origin'] = origin
    return headers
```

## Endpoint Pattern

Every endpoint must handle OPTIONS preflight:

```python
@app.route('/api/data', methods=['POST', 'OPTIONS'])
def get_data():
    origin = request.headers.get('Origin', '')
    headers = get_cors_headers(origin)

    if request.method == 'OPTIONS':
        return ('', 204, headers)

    try:
        data = request.get_json() or {}
        result = process(data)
        return (jsonify(result), 200, headers)
    except Exception as e:
        return (jsonify({'error': str(e)}), 500, headers)
```

**Key:** Return CORS headers on ALL responses — success, error, and OPTIONS.

## Quick Reference

| Header | Purpose | Value |
|--------|---------|-------|
| `Access-Control-Allow-Origin` | Which origins can call you | Exact origin from whitelist |
| `Access-Control-Allow-Methods` | Allowed HTTP methods | `POST, OPTIONS, GET` |
| `Access-Control-Allow-Headers` | Allowed request headers | `Content-Type, Authorization` |
| `Access-Control-Max-Age` | Preflight cache duration (seconds) | `3600` |
| `Access-Control-Allow-Credentials` | Allow cookies/auth headers | `true` (if needed) |

## When Credentials Are Needed

If the frontend sends cookies or `Authorization` headers:

```python
def get_cors_headers(origin: str) -> dict:
    headers = {
        'Access-Control-Allow-Methods': 'POST, OPTIONS, GET',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        'Access-Control-Allow-Credentials': 'true',  # Required
        'Access-Control-Max-Age': '3600',
    }
    if origin in ALLOWED_ORIGINS:
        headers['Access-Control-Allow-Origin'] = origin  # Must be exact, NOT *
    return headers
```

**Rule:** When `Allow-Credentials: true`, `Allow-Origin` MUST be an exact origin, never `*`.

## Why Not flask-cors?

The `flask-cors` library works fine for simple cases. Use the manual pattern when you need:
- Explicit origin validation (not wildcard)
- Different CORS rules per endpoint
- Custom logic (logging, rate limiting per origin)

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `Access-Control-Allow-Origin: *` in production | Use explicit whitelist — `*` allows any site to call you |
| Not handling OPTIONS preflight | Add `'OPTIONS'` to methods, return 204 with headers |
| CORS headers only on success responses | Return headers on error responses too — browser needs them |
| Forgetting `Content-Type` in Allow-Headers | Frontend can't send JSON without it |
| Using flask-cors with credentials + wildcard | Credentials require exact origin, not `*` — browser blocks it |
| Localhost port mismatch | `localhost:3000` and `localhost:5000` are different origins |
