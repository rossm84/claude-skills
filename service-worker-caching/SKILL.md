---
name: service-worker-caching
description: Use when adding offline support, PWA caching, or service workers to a web app. Use when the user wants their web app to work offline, load faster, or cache static assets. Use when writing sw.js or service-worker.js files.
---

# Service Worker Caching

## Overview

Network-first strategy for local assets, skip external services entirely. Version-based cache invalidation with automatic cleanup of old caches.

## Complete Service Worker

```javascript
const CACHE_NAME = 'my-app-v1.0.0';

const STATIC_ASSETS = [
  '/app/',
  '/app/index.html',
  '/app/styles.css',
  '/app/main.js',
];

// Install: pre-cache static assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(STATIC_ASSETS))
      .then(() => self.skipWaiting())  // Activate immediately
  );
});

// Activate: delete old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys.filter((key) => key !== CACHE_NAME)
            .map((key) => caches.delete(key))
      )
    )
  );
  self.clients.claim();  // Take control of open tabs
});

// Fetch: network-first for local, skip external
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // Skip non-GET
  if (event.request.method !== 'GET') return;

  // Skip external services (auth, APIs, CDNs)
  if (url.hostname.includes('googleapis') ||
      url.hostname.includes('firebase') ||
      url.hostname.includes('gstatic.com')) {
    return;  // Let browser handle normally
  }

  // Network-first for local assets
  if (url.origin === self.location.origin) {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          if (response.ok) {
            const clone = response.clone();
            caches.open(CACHE_NAME)
              .then((cache) => cache.put(event.request, clone))
              .catch(() => {});
          }
          return response;
        })
        .catch(() => caches.match(event.request))  // Offline fallback
    );
  }
});
```

## Registration (in your HTML)

```javascript
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/app/sw.js')
    .then((reg) => console.log('SW registered'))
    .catch((err) => console.warn('SW failed:', err));
}
```

## Caching Strategies

| Strategy | When to Use | How |
|----------|------------|-----|
| **Network-first** | Pages, API responses, frequently updated assets | Try network, cache on success, fallback to cache |
| **Cache-first** | Fonts, images, rarely-changing assets | Try cache, fallback to network |
| **Stale-while-revalidate** | When speed matters but freshness is nice | Return cache immediately, update cache in background |
| **Network-only** | Auth, payments, real-time data | Don't cache, let request pass through |

## Version Bumping

When you deploy new code:
1. Update `CACHE_NAME` version string
2. `activate` event automatically deletes old caches
3. `skipWaiting()` ensures new SW takes over immediately

```javascript
// Old: 'my-app-v1.0.0'
// New: 'my-app-v1.1.0'  ← change this on deploy
const CACHE_NAME = 'my-app-v1.1.0';
```

## What to Skip

**Always skip these in the fetch handler** (let browser handle them):
- Firebase Auth (`firestore`, `googleapis`, `firebase`)
- Payment processors
- Analytics
- WebSocket connections
- Third-party auth (OAuth redirects)

If you cache auth tokens, users get stale/invalid auth and can't sign in.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Caching Firebase/auth requests | Skip external hostnames entirely — `return` without `respondWith` |
| No `skipWaiting()` | Without it, new SW waits until ALL tabs close |
| No `clients.claim()` | Without it, open tabs don't use new SW until refresh |
| Forgetting `response.clone()` | Response body can only be read once — clone before caching |
| Not updating CACHE_NAME on deploy | Users get stale cached assets forever |
| Caching non-GET requests | POST/PUT/DELETE should never be cached |
| Missing assets in STATIC_ASSETS | Pre-cache fails silently if any asset 404s — check paths |
| Using cache-first for HTML | Users never see updates. Use network-first for pages |
