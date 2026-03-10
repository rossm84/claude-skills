---
name: graceful-degradation-apis
description: Use when building APIs that call external services, databases, or third-party APIs. Use when designing error handling for multi-dependency backends. Use when enriching data from optional sources.
---

# Graceful Degradation for APIs

## Overview

Return partial data instead of errors when external dependencies fail. No single service failure should crash the entire response.

## Core Pattern

**Return-and-continue, not throw-and-abort.**

Every external call follows this structure:

```python
def enrich_with_external(items):
    client = _get_client()
    if client is None:
        logger.info("Service unavailable, skipping enrichment")
        return items  # Return unmodified data

    try:
        # Do enrichment
        enriched = client.query(items)
        return enriched
    except Exception as e:
        logger.warning("Enrichment failed (graceful fallback): %s", e)
        return items  # Return unmodified data
```

**Key rules:**
1. Check client availability before attempting calls
2. Log warnings (not errors) for expected fallbacks
3. Return original data unmodified on failure
4. Never let enrichment failures propagate to the caller

## Quick Reference

| Situation | Pattern | Return |
|-----------|---------|--------|
| Client init fails | Cache `None`, check before use | Original data |
| API call fails | `try/except`, log warning | Original data |
| Timeout | Set explicit timeout, catch | Original data |
| Partial results | Merge what you got | Partially enriched data |
| All sources fail | Return base response | Unenriched but valid response |

## Error Return Convention

For functions that callers need to know about failures, use `(data, error)` tuples:

```python
def read_cache(key):
    """Returns (data_dict, None) or (None, error_str)."""
    client = _get_client()
    if not client:
        return None, "Service unavailable"
    try:
        data = client.get(key)
        return data, None
    except Exception as e:
        logger.warning("Cache read %s failed: %s", key, e)
        return None, str(e)
```

## Lazy Client Initialization

Cache clients globally. Init on first use. Return `None` if unavailable:

```python
_client = None

def _get_client():
    global _client
    if _client is not None:
        return _client
    try:
        _client = SomeClient(project="my-project")
        return _client
    except Exception as e:
        logger.warning("Client init failed: %s", e)
        return None
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Raising exceptions from optional enrichment | Catch and return original data |
| Logging at ERROR level for expected fallbacks | Use WARNING — these are expected |
| Silently swallowing errors (no logging) | Always `logger.warning()` with context |
| Initializing clients eagerly at import time | Lazy init — app starts even if service is down |
| Returning empty data instead of original | Always pass through the original input unchanged |
