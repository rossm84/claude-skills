---
name: root-cause-tracing
description: Use when debugging production errors, tracing failures across services, or investigating why something broke. Structured approach to trace errors back to their original trigger across logs, code, and infrastructure.
---

# Root Cause Tracing

Structured approach to trace an error back to its original trigger. Use this when you have a symptom (error message, broken feature, failed job) and need to find the root cause.

## Process

### 1. Capture the symptom
Document exactly what's failing:
- Error message (exact text)
- When it started (or when first noticed)
- What changed recently (deploys, config, dependencies)
- Who/what is affected (all users, specific endpoint, one cron job)

### 2. Trace backwards
Follow the error chain from symptom to source:

```
Symptom → immediate error → calling code → trigger → root cause
```

At each step:
- Read the error message literally (not what you think it means)
- Find the exact line that throws/logs the error
- Check what calls that code
- Check what changed at that call site

### 3. Evidence collection

**Logs:**
```bash
# App Engine
gcloud app logs read --service=community-export --limit=100 2>&1 | grep -i error

# Cloud Functions
gcloud functions logs read FUNCTION_NAME --limit=50 --project=spotify-community

# Structured logs
gcloud logging read 'severity>=ERROR AND resource.type="gae_app"' --project=spotify-community --limit=20 --format=json
```

**Git history:**
```bash
# What changed recently?
git log --oneline --since="2 days ago"

# What changed in a specific file?
git log --oneline -10 -- path/to/file.py

# Diff between last known good and current
git diff GOOD_COMMIT..HEAD -- path/to/file.py
```

**Runtime state:**
```bash
# Check if a service is responding
curl -s -o /dev/null -w "%{http_code}" https://service-url/health

# Check cron jobs
gcloud scheduler jobs list --project=spotify-community

# Check recent deploys
gcloud app versions list --service=community-export --project=spotify-community --sort-by=~version.createTime --limit=5
```

### 4. Hypothesize and verify
For each hypothesis:
1. State what you think happened
2. State what evidence would confirm or refute it
3. Gather that evidence
4. Accept or reject

Do NOT fix anything until the root cause is confirmed. A fix without understanding causes a second bug later.

### 5. Common root cause categories

| Category | Signals | Check |
|---|---|---|
| **Deploy regression** | "Worked yesterday" | `git log --oneline -5`, diff the deploy |
| **Config/secret change** | Auth errors, 403s, connection refused | Check env vars, secret versions, IAM |
| **Dependency update** | Import errors, type errors, new behaviour | `pip3 list`, `npm list`, lockfile diff |
| **Data shape change** | KeyError, TypeError, null pointer | Check API response, DB schema, upstream feed |
| **Resource exhaustion** | Timeouts, OOM, quota exceeded | Check quotas, memory, disk, connection pools |
| **External service** | Intermittent failures, DNS, TLS | Check status pages, try curl, check certs |
| **Race condition** | Intermittent, load-dependent | Check concurrency, locking, transaction isolation |

### 6. Document the finding
When you find the root cause, state:
- **What** broke (the symptom)
- **Why** it broke (the root cause)
- **When** it broke (the trigger event)
- **Fix** (what to change)
- **Prevention** (how to stop it happening again)
