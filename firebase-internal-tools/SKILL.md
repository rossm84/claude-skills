---
name: firebase-internal-tools
description: Use when deploying internal tools on Firebase and GCP. Use when setting up Firebase Hosting, App Engine backends, Firestore security rules, or Cloud Functions for internal company tools. Use when configuring multi-app Firebase projects.
---

# Firebase + GCP for Internal Tools

## Overview

Three-tier architecture: Firebase Hosting (SPAs) + App Engine (stateless Python backend) + Firestore (data with security rules). One GCP project, multiple apps.

## Architecture

```
Firebase Hosting (CDN)     → SPAs (HTML/CSS/JS)
App Engine (Python/Flask)  → API backend (stateless)
Firestore                  → Data + security rules
Cloud Functions            → Glue logic, scheduled jobs
GCS                        → Cache for precomputed data
```

## Deploy Commands

```bash
# Frontend (all hosted SPAs)
firebase deploy --only hosting:TARGET_NAME

# Backend API
cd api-dir && gcloud app deploy app.yaml cron.yaml --project PROJECT_ID --quiet

# Cloud Functions
firebase deploy --only functions

# Firestore rules
firebase deploy --only firestore:rules
```

## Multi-App Hosting (firebase.json)

```json
{
  "hosting": [{
    "target": "my-project",
    "public": "public",
    "headers": [
      {
        "source": "**",
        "headers": [
          {"key": "X-Frame-Options", "value": "SAMEORIGIN"},
          {"key": "X-Content-Type-Options", "value": "nosniff"},
          {"key": "Content-Security-Policy", "value": "default-src 'self'; script-src 'self' 'unsafe-inline' https://www.gstatic.com ..."}
        ]
      },
      {
        "source": "**/*.@(js|css)",
        "headers": [{"key": "Cache-Control", "value": "public, max-age=0, must-revalidate"}]
      },
      {
        "source": "**/*.@(jpg|jpeg|gif|png|svg|webp)",
        "headers": [{"key": "Cache-Control", "value": "public, max-age=86400"}]
      }
    ],
    "rewrites": [
      {"source": "/app/**", "destination": "/app/index.html"},
      {"source": "/forge/**", "destination": "/forge/index.html"},
      {"source": "**", "destination": "/index.html"}
    ]
  }]
}
```

**Key:** JS/CSS cache `max-age=0` (always revalidate). Images cached 1 day. SPA rewrites per app directory.

## Firestore Security Rules (Domain Whitelist)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isApprovedUser() {
      return request.auth != null &&
             request.auth.token.email != null &&
             request.auth.token.email.matches('.*@mycompany[.]com$');
    }
    function isAdmin() {
      return request.auth != null &&
             exists(/databases/$(database)/documents/admins/$(request.auth.token.email));
    }

    // Standard read/write for approved users
    match /myCollection/{docId} {
      allow read, write: if isApprovedUser();
    }
    // Immutable audit logs
    match /auditLog/{logId} {
      allow create: if isApprovedUser();
      allow read: if isApprovedUser();
      allow update, delete: if false;
    }
    // Admin-only management
    match /admins/{email} {
      allow read: if isApprovedUser();
      allow write: if isAdmin();
    }
    // Default deny
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**Patterns:** Domain regex whitelist, admin lookup in Firestore, immutable logs (`update, delete: if false`), default deny at bottom.

## App Engine Config (app.yaml)

```yaml
runtime: python312
instance_class: F2
service: my-service

entrypoint: gunicorn -b :$PORT -w 4 --threads 8 --timeout 300 main:app

automatic_scaling:
  min_instances: 0    # Scale to zero (saves cost)
  max_instances: 3
  target_cpu_utilization: 0.65

inbound_services:
  - warmup
```

**Important:** Use Secret Manager for credentials, NOT `env_variables` in `app.yaml`.

## Quick Reference

| Concern | Solution |
|---------|----------|
| Auth | Firebase Auth, check email domain in rules |
| Secrets | Google Cloud Secret Manager (not env vars in app.yaml) |
| CSP | Allowlist Firebase CDNs, googleapis, your App Engine domain |
| Cron jobs | `cron.yaml` for App Engine scheduled tasks |
| Cache | JS/CSS: no-cache. Images: 1 day. API: GCS + in-memory |
| Scaling | min_instances: 0 for cost, warmup endpoint for cold starts |
| Health check | `/health` returns 200, `/_ah/warmup` for App Engine |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Secrets in `app.yaml` env_variables | Use Secret Manager + `secretmanager.versions.access` |
| Missing default deny rule in Firestore | Always end with `match /{document=**} { allow: if false }` |
| No CSP headers | Add to firebase.json hosting headers |
| Caching JS aggressively | Use `max-age=0, must-revalidate` for code files |
| No warmup endpoint | Add `/_ah/warmup` route for faster cold starts |
| Eagerly scaling App Engine | `min_instances: 0` saves money for internal tools |
