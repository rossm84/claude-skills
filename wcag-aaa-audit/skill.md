---
name: wcag-aaa-audit
description: Pre-deploy WCAG 2.2 accessibility audit for the Migration Planning Dashboard. MUST run before any deploy of public/app/ files. Checks contrast, keyboard, ARIA, semantics, target sizes. Use when modifying any file in public/app/ or before deploying frontend.
trigger: before deploying frontend, after modifying files in public/app/
---

# WCAG 2.2 Pre-Deploy Accessibility Audit

**Run this before every frontend deploy.** The app claims AA compliance and targets AAA.

## Automated Checks (run these)

```bash
# 1. Forbidden text colours on dark backgrounds (must use AAA-safe alternatives)
echo "=== Checking forbidden text colours ==="
grep -rn 'color.*#1db954\|color.*#10b981\|color.*#f59e0b\|color.*#ef4444\|color.*#6366f1\|color.*#8b5cf6\|color.*#3b82f6\|color.*#f87171' public/app/*.js public/app/*.html public/app/*.css | grep -v 'background\|border\|accent\|stroke\|fill\|var(--\|//\|/\*\|\.btn-danger:hover'

# 2. Clickable div/span without keyboard support
echo "=== Checking keyboard accessibility ==="
grep -n '<div.*onclick\|<span.*onclick' public/app/*.html public/app/*.js | grep -v 'role="button"\|tabindex\|<button'

# 3. Images/icons without alt text or aria-label
echo "=== Checking non-text content ==="
grep -n '<img ' public/app/*.html | grep -v 'alt=\|aria-'
grep -n '<svg ' public/app/*.html | head -5 | grep -v 'aria-hidden\|aria-label\|role="img"'

# 4. Modals without dialog role
echo "=== Checking modal semantics ==="
grep -n 'role="dialog"' public/app/*.html public/app/*.js | head -10

# 5. Form inputs without labels or aria-describedby
echo "=== Checking form labels ==="
grep -n '<select\|<input\|<textarea' public/app/crud-forms.js | grep -v 'aria-\|id="\|type="hidden"\|type="checkbox"' | head -10

# 6. Line-height below 1.5
echo "=== Checking line-height ==="
grep -n 'line-height:\s*1[.;]\|line-height:\s*1$' public/app/spotify-theme.css public/app/styles.css | grep -v '1\.[5-9]\|font-size'
```

## Manual Checklist

After automated checks pass, verify these:

### Contrast (1.4.6 — AAA 7:1)

**Approved text colour palette (all 7:1+ on #121212):**

| Variable | Hex | Ratio | Usage |
|----------|-----|-------|-------|
| `--spotify-text` | `#ffffff` | 18.1:1 | Primary text |
| `--spotify-text-subdued` | `#c8c8c8` | 11.2:1 | Secondary text |
| `--spotify-text-secondary` | `#bfbfbf` | 10.2:1 | Tertiary text |
| `--spotify-text-muted` | `#a0a0a0` | 7.2:1 | Muted text (minimum) |
| `--spotify-green-text` | `#4ade80` | 10.8:1 | Green text, focus rings |
| `--color-success` | `#34d399` | 9.7:1 | Success text |
| `--color-warning` | `#fbbf24` | 11.2:1 | Warning text |
| `--color-danger` | `#fca5a5` | 9.1:1 | Danger/error badges |
| `--color-info` | `#a5b4fc` | 7.5:1 | Info/defer badges |
| `--color-purple` | `#c4b5fd` | 8.2:1 | Purple badges |
| `--color-blue` | `#93bbfd` | 7.8:1 | Blue badges |

**Border contrast:** `--spotify-border: rgba(255,255,255,0.25)` gives ~3.2:1 on #121212. Never reduce below 0.25 opacity.

To verify a new colour:
```bash
python3 -c "
def lum(h):
    r,g,b=[int(h[i:i+2],16)/255 for i in(0,2,4)]
    def f(v): return v/12.92 if v<=0.04045 else((v+0.055)/1.055)**2.4
    return 0.2126*f(r)+0.7152*f(g)+0.0722*f(b)
l1,l2=lum('NEW_HEX'),lum('121212')
if l1<l2:l1,l2=l2,l1
print(f'{(l1+0.05)/(l2+0.05):.2f}:1')
"
```

### Target Size (2.5.5 — 44px)

- Every `<button>`, `[role="button"]`, checkbox, radio must be at least 44x44px
- Global CSS handles this, but inline `width`/`height` can override — check new elements
- Icon-only buttons MUST have `aria-label`

### Keyboard (2.1.3)

- **Never** use `<div onclick>` or `<span onclick>` — use `<button>` instead
- All modals must have focus trapping (`_trapFocus`/`_releaseFocus`)
- All modals must have `role="dialog"`, `aria-modal="true"`, `aria-labelledby`

### Tab Semantics (4.1.2)

- Tab buttons need `role="tab"`, `aria-controls="<pane-id>"`, `aria-selected`
- Tab panes need `role="tabpanel"`, `aria-labelledby="<button-id>"`
- Tab button IDs are auto-assigned in `setupTabs()` as `<tab>TabBtn`

### Form Fields (3.3.5)

- New form fields should have `<small>` helper text with unique `id`
- Link with `aria-describedby` on the input/select/textarea

### Abbreviations (3.1.3)

On first use in new UI text: `<abbr title="Full Name">ABBR</abbr>`
Known: MVP, BRD, AI, CSV, P1, P1.5, P2, BL, CRUD, API, BPS, AOP

### Error Prevention (3.3.6)

- Destructive actions: use `await window.appConfirm('Title', 'message', { danger: true })`
- Regular saves: CRUD forms already have undo via `showUndoNotification`
- New bulk operations must confirm first

### Reduced Motion (2.3.3)

- `.anim-off` class and `prefers-reduced-motion` suppress animations
- Never use `!important` on `animation-duration` in regular CSS

### Notification Container

- Uses `aria-relevant="additions"` (not `aria-atomic="true"`)
- Messages must be HTML-escaped before `innerHTML` insertion

## Known AAA Gaps (Documented)

These AAA criteria are not fully met and are documented in the WCAG modal:
- **3.1.5 Reading Level** — no simplified alternatives for complex content
- **3.1.6 Pronunciation** — no pronunciation mechanism
- **1.4.8 Visual Presentation** — partial (no user-customizable foreground/background colours)

## When to Run

- Before `firebase deploy --only hosting`
- After modifying any file in `public/app/`
- After adding new interactive elements, modals, or form fields
