---
name: ai-model-fallback
description: Use when integrating AI models into backend services. Use when building multi-model resilience, provider failover, or unified AI helpers. Use when calling Gemini, GPT, Claude, or other LLM APIs from Python backends.
---

# AI Model Fallback Pattern

## Overview

Create a single unified helper function that tries the primary AI model and falls back to a secondary. Callers never deal with provider-specific logic.

## Core Pattern

```python
def ai_call(system_prompt, user_prompt, max_tokens=500, temperature=0.3):
    """Try primary model, fall back to secondary. Returns text or None."""
    # Try primary (e.g., Gemini via Vertex AI REST)
    result = _try_primary(system_prompt, user_prompt, max_tokens, temperature)
    if result:
        return result

    # Fallback (e.g., GPT-4o-mini via OpenAI SDK)
    return _try_fallback(system_prompt, user_prompt, max_tokens, temperature)
```

**Key rules:**
1. One function, one interface — callers don't know which model responded
2. Parameterize `temperature` and `max_tokens` (don't hardcode)
3. Return `None` if both fail — let caller decide what to do
4. Log which model is being used (helps debugging)

## Gemini via Vertex AI REST (No SDK)

No Vertex AI SDK needed. Use `google.auth` + `requests`:

```python
import google.auth
import google.auth.transport.requests
import requests

_credentials = None

def _get_token():
    global _credentials
    if _credentials is None:
        _credentials, _ = google.auth.default(
            scopes=["https://www.googleapis.com/auth/cloud-platform"]
        )
    _credentials.refresh(google.auth.transport.requests.Request())
    return _credentials.token

def _try_gemini(system_prompt, user_prompt, max_tokens, temperature):
    token = _get_token()
    if not token:
        return None
    url = (f"https://{LOCATION}-aiplatform.googleapis.com/v1/"
           f"projects/{PROJECT}/locations/{LOCATION}/"
           f"publishers/google/models/{MODEL}:generateContent")
    payload = {
        "contents": [{"role": "user", "parts": [{"text": f"{system_prompt}\n\n{user_prompt}"}]}],
        "generationConfig": {
            "responseMimeType": "application/json",
            "maxOutputTokens": max_tokens,
            "temperature": temperature,
        },
    }
    try:
        resp = requests.post(url, json=payload,
            headers={"Authorization": f"Bearer {token}"}, timeout=60)
        if resp.status_code == 200:
            return resp.json()["candidates"][0]["content"]["parts"][0]["text"].strip()
        logger.warning("Gemini returned %s: %s", resp.status_code, resp.text[:200])
    except Exception as e:
        logger.warning("Gemini failed, falling back: %s", e)
    return None
```

## OpenAI Fallback

```python
def _try_openai(system_prompt, user_prompt, max_tokens, temperature):
    client = _get_openai_client()
    if not client:
        return None
    try:
        resp = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            max_tokens=max_tokens,
            temperature=temperature,
            response_format={"type": "json_object"},
        )
        return resp.choices[0].message.content.strip()
    except Exception as e:
        logger.warning("OpenAI fallback also failed: %s", e)
        return None
```

## Quick Reference

| Concern | Approach |
|---------|----------|
| Credential caching | Global var, lazy init, refresh on demand |
| JSON responses | Gemini: `responseMimeType: "application/json"`, OpenAI: `response_format: {"type": "json_object"}` |
| System prompt | Gemini: prepend to user text. OpenAI: separate `system` role message |
| Timeout | Always set explicit timeout (60s recommended) |
| Rate limits | Use separate worker pools (e.g., 3 workers for AI calls) |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Provider-specific try/catch at every call site | Centralize in one helper function |
| No timeout on AI calls | Always `timeout=60` — LLM calls can hang |
| Hardcoded temperature/tokens | Parameterize — analysis needs `0.2`, creative needs `0.7` |
| Installing heavy SDK for one model | Gemini works fine via REST + `google.auth` |
| Not logging which model responded | Add `logger.info("Using %s", model_name)` for debugging |
