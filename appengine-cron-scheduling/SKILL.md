---
name: appengine-cron-scheduling
description: Use when building scheduled/recurring jobs on App Engine with user-configurable frequency — daily, weekly, custom intervals — using a single hourly cron that checks which jobs are due
---

# App Engine Cron with User-Configurable Schedules

## Overview

Single hourly App Engine cron job that reads schedule configs from Firestore, checks which are due, and executes them. Simpler than per-schedule Cloud Scheduler jobs when you have user-configurable frequencies.

## Architecture

```
cron.yaml (hourly) → /api/schedules/run → Read Firestore → Check due → Execute → Update lastRunAt
```

## cron.yaml

```yaml
cron:
- description: "Run scheduled jobs"
  url: /api/schedules/run
  schedule: every 1 hours
  timezone: UTC
  target: your-service
```

## Firestore Schema

```
frequency: "daily" | "weekly" | "custom"
weeklyDay: "monday" | "tuesday" | ... | "sunday"  (only if weekly)
customIntervalHours: 6 | 12 | 24 | ...            (only if custom)
runAtHour: 0-23                                     (UTC hour)
active: true | false
lastRunAt: Timestamp | null
lastRunStatus: "success" | "error" | null
```

## Due-Check Logic

```python
from datetime import datetime

now = datetime.utcnow()
current_hour = now.hour

# Map day name to weekday int
day_map = {'monday': 0, 'tuesday': 1, 'wednesday': 2, 'thursday': 3,
           'friday': 4, 'saturday': 5, 'sunday': 6}

if frequency == 'daily':
    if current_hour == run_at_hour:
        is_due = (last_run_at is None) or (last_run_at.date() < now.date())

elif frequency == 'weekly':
    day_name = (config.get('weeklyDay') or 'monday').lower()
    run_day = day_map.get(day_name, 0)
    if now.weekday() == run_day and current_hour == run_at_hour:
        is_due = (last_run_at is None) or ((now - last_run_at).days >= 7)

elif frequency == 'custom':
    interval_hours = config.get('customIntervalHours', 24)
    if last_run_at is None:
        is_due = True
    else:
        elapsed = (now - last_run_at).total_seconds() / 3600
        is_due = elapsed >= interval_hours
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Storing day as integer, frontend sends string | Use the same type everywhere. Day names ("monday") are more readable than ints (0). Convert at the check point. |
| `>= 6` for weekly threshold | Use `>= 7`. With `>= 6` a schedule could fire on day 6 if the weekday check passes (edge case with timezone drift). |
| Firestore timestamps have timezone info | Always strip: `last_run_at.replace(tzinfo=None)` before comparing with `datetime.utcnow()`. |
| No cron header check | App Engine sets `X-Appengine-Cron: true` on real cron calls. External requests have this header stripped. **Return 403 if missing** — don't just log a warning. |
| Processing too many schedules | App Engine cron has 10-min timeout. Process oldest-due first; overflow gets caught by next hourly run. |

## Cron Security

```python
@app.route('/api/schedules/run', methods=['GET'])
def run_schedules():
    if request.headers.get('X-Appengine-Cron') != 'true':
        return jsonify({'error': 'Forbidden'}), 403  # MUST return, not just log
    # ... execute schedules
```

App Engine **strips** `X-Appengine-Cron` from external requests. You cannot spoof it from outside.

## After Execution

```python
from google.cloud.firestore import SERVER_TIMESTAMP

doc_ref.update({
    'lastRunAt': SERVER_TIMESTAMP,  # Server-side timestamp, not client
    'lastRunStatus': 'success',     # or 'error'
    'lastRunThreadCount': count,    # Domain-specific metrics
})
```

Use `SERVER_TIMESTAMP` not `datetime.utcnow()` to avoid clock skew between App Engine instances.
