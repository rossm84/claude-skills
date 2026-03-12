---
name: wcag-aaa-audit
description: Run WCAG 2.2 AAA compliance checks on the Migration Planning Dashboard. Use when modifying any file in public/app/ to ensure accessibility standards are maintained.
trigger: after modifying files in public/app/
---

# WCAG 2.2 AAA Audit

Run this skill after any change to files in `public/app/` to verify WCAG 2.2 Level AAA compliance is maintained.

## Checklist

After making changes, verify each of these:

### 1. Contrast (1.4.6 — 7:1 minimum)

**Never use these raw colours as text on dark backgrounds:**
- `#1db954` (Spotify green) — use `#4ade80` or `var(--spotify-green-text)` for text
- `#10b981` (emerald) — use `#34d399` or `var(--color-success)` for text
- `#f59e0b` (amber) — use `#fbbf24` or `var(--color-warning)` for text
- Any gray darker than `#a0a0a0` for text on `#121212`

**Approved text colour palette (all 7:1+ on #121212):**
| Variable | Hex | Ratio |
|----------|-----|-------|
| `--spotify-text` | `#ffffff` | 18.1:1 |
| `--spotify-text-subdued` | `#c8c8c8` | 11.2:1 |
| `--spotify-text-secondary` | `#bfbfbf` | 10.2:1 |
| `--spotify-text-muted` | `#a0a0a0` | 7.2:1 |
| `--spotify-green-text` | `#4ade80` | 10.8:1 |
| `--color-success` | `#34d399` | 9.7:1 |
| `--color-warning` | `#fbbf24` | 11.2:1 |

To verify a new colour, run:
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

### 2. Target Size (2.5.5 — 44px minimum)

Every `<button>`, `[role="button"]`, `<a onclick>`, checkbox, radio must be at least 44x44px.

- If adding inline-styled buttons with small padding, add `min-width: 44px; min-height: 44px;`
- The global CSS rule (`spotify-theme.css`) sets `min-width/height: 44px` on buttons, but inline styles can override it
- Icon-only buttons MUST have `aria-label`

### 3. Keyboard (2.1.3 — No Exception)

If you add a `<div onclick>` or `<span onclick>`:
- Add `role="button" tabindex="0"`
- Add `onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();this.click()}"`
- Or better: use a `<button>` element instead

### 4. Line Height (1.4.8 — minimum 1.5)

- Body has `line-height: 1.5` globally
- Never set `line-height` below 1.5 on text content
- Exception: stat numbers, icon containers, and non-text elements can use tighter line-heights

### 5. Abbreviations (3.1.4)

On first use of abbreviations in new UI text, wrap with `<abbr title="Full Name">ABBR</abbr>`.
Known abbreviations: MVP, BRD, AI, CSV, FAB, P1, P1.5, P2, BL, CRUD, API.

### 6. Focus Visible (2.4.7)

The global `:focus-visible` rule handles this. Don't add `outline: none` without a `:focus-visible` replacement.

### 7. Reduced Motion (2.3.3)

- The `.anim-off` CSS class and `prefers-reduced-motion` media query suppress animations
- Don't add animations that bypass these (no `!important` on animation-duration)

### 8. Help Text (3.3.5)

New form fields should have `<small>` helper text or `aria-describedby` linking to a help element.

### 9. Error Prevention (3.3.6)

Any new destructive action (delete, bulk update) must use `confirm()` or a confirmation modal.

## Quick Verification

After changes, do a quick scan:
```bash
# Check for forbidden text colours
grep -rn 'color.*#1db954\|color.*#10b981\|color.*#f59e0b' public/app/*.js public/app/*.html | grep -v 'background\|border\|accent\|stroke\|fill\|var(--spotify-green,'

# Check for div/span onclick without keyboard
grep -n 'div onclick\|span onclick' public/app/*.html public/app/*.js | grep -v 'role="button"'

# Check for line-height below 1.5 on text
grep -n 'line-height: 1[.;]\|line-height: 1$' public/app/spotify-theme.css public/app/styles.css
```
