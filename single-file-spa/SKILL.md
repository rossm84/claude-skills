---
name: single-file-spa
description: Use when building internal web tools, dashboards, or admin interfaces. Use when the user wants a quick web app without build tools, bundlers, or frameworks. Use when creating Firebase-hosted single-page applications.
---

# Single-File SPA Architecture

## Overview

One HTML file with inline CSS and JS. No build step, no bundler, no framework. Deploy by copying one file. Best for internal tools under ~5K lines.

## When to Use / Not Use

| Use | Don't Use |
|-----|-----------|
| Internal tools, dashboards | Public-facing products |
| 1-3 developers | Teams > 3 people |
| < 5K lines total | > 10K lines |
| Rapid iteration needed | Complex state management needed |
| Firebase Hosting | SEO matters |

## File Structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tool Name</title>
  <style>
    /* All CSS inline */
    :root {
      --bg: #1a1a2e;
      --text: #e0e0e0;
      --accent: #1db954;
      --radius: 8px;
    }
    .view { display: none; }
    .view.active { display: flex; flex-direction: column; }
  </style>
</head>
<body>
  <!-- All views in DOM simultaneously -->
  <nav><!-- Tab buttons --></nav>
  <div id="view-dashboard" class="view active">...</div>
  <div id="view-settings" class="view">...</div>

  <!-- Firebase from CDN (no npm install) -->
  <script src="https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.14.1/firebase-auth-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.14.1/firebase-firestore-compat.js"></script>

  <script>
    // All JS inline
    firebase.initializeApp({ /* config */ });
  </script>
</body>
</html>
```

## Key Patterns

### View Switching (No Router)

```javascript
function showView(viewId) {
  document.querySelectorAll('.view').forEach(v => v.classList.remove('active'));
  document.getElementById(viewId)?.classList.add('active');
  // Update nav highlight
  document.querySelectorAll('.nav-tab').forEach(t => t.classList.remove('selected'));
  document.querySelector(`[data-view="${viewId}"]`)?.classList.add('selected');
}
```

All views stay in DOM. No mount/unmount lifecycle. Data persists between view switches.

### Feature Flags

```javascript
window.HIDE_RAID = true;  // Set false to restore hidden tab
// In render:
if (!window.HIDE_RAID) renderRaidTab();
```

### Debounced Rendering (for tables)

```javascript
let _suppressRenderUntil = 0;

function renderDebounced() {
  if (Date.now() < _suppressRenderUntil) return;
  renderTable();
}

function suppressRender() {
  _suppressRenderUntil = Date.now() + 300;
}
```

### Fast Table Rendering

```javascript
// Build HTML strings, insert once (faster than createElement loops)
const rows = items.map(item => `<tr>
  <td><input type="checkbox" onchange="toggle('${item.id}')"></td>
  <td>${escapeHtml(item.name)}</td>
</tr>`);
tbody.innerHTML = rows.join('');
```

### Set-Based Bulk Selection

```javascript
const selected = new Set();
function toggle(id) {
  selected.has(id) ? selected.delete(id) : selected.add(id);
  updateToolbar();
}
function bulkAction(action) {
  for (const id of selected) { action(id); }
}
```

### CSS Variables for Theming

Define all colors/spacing as CSS variables in `:root`. Swap themes by changing 5-10 variables.

### Version Tracking

```html
<!-- VERSION: 20260310t143000 -->
<script>window.APP_VERSION = "2.8.0";</script>
```

Visible in source. Service worker cache name includes version.

## Quick Reference

| Need | Pattern |
|------|---------|
| Routing | View switching with `display:none/flex` |
| State | Global variables + Sets for selections |
| Auth | Firebase Auth CDN, check `@domain.com` |
| Data | Firestore CDN, wrap in ops module |
| Tables | HTML string concat + `innerHTML` |
| Bulk ops | `Set` for selection tracking |
| Themes | CSS custom properties in `:root` |
| Deploy | `firebase deploy --only hosting` |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using `createElement` in loops for large tables | String concat + single `innerHTML` is 5-10x faster |
| Mounting/unmounting views | Keep all in DOM, toggle `display` |
| npm/webpack for an internal tool | CDN imports, zero build |
| No debounce on rapid re-renders | Suppress renders for 300ms during bulk ops |
| Escaping HTML in templates | Always `escapeHtml()` for user-provided data |
