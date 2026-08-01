# 07 — UI/UX Design System

**Project:** qwe1
**Status:** `[DECIDED]`
**Owner:** Design

> Design tokens are the single source of truth. Implementation maps tokens to Flutter `ThemeData` (`ColorScheme`, `TextTheme`, `AppBarTheme`, etc.) in `app/lib/ui/theme/`.

---

## 1. Design principles

1. **Calm competence** — trustworthy, not flashy. Data first, decoration last.
2. **Glanceable** — the most important information is readable in 2 seconds.
3. **Fast by feel** — instant feedback on every action; optimistic UI where safe.
4. **Mobile-native** — touch targets ≥ 48dp, gestures, platform-appropriate controls.
5. **Accessible** — WCAG AA contrast, scalable text, full screen-reader support.

## 2. Color palette

### Light mode
| Token | Value | Usage |
|-------|-------|-------|
| `background` | `#FAFAF9` | App background |
| `surface` | `#FFFFFF` | Cards, sheets |
| `surfaceVariant` | `#F2F2F0` | Raised wells, inputs |
| `onSurface` | `#1C1917` | Primary text |
| `onSurfaceMuted` | `#57534E` | Secondary text |
| `primary` | `#2563EB` | Accent, interactive |
| `onPrimary` | `#FFFFFF` | Text on primary |
| `success` | `#16A34A` | Healthy/online |
| `warning` | `#D97706` | Caution, degraded |
| `danger` | `#DC2626` | Errors, critical |
| `info` | `#0891B2` | Informational |
| `border` | `#E7E5E4` | Hairline dividers |
| `overlay` | `rgba(0,0,0,0.5)` | Scrims |

### Dark mode
| Token | Value |
|-------|-------|
| `background` | `#0C0A09` |
| `surface` | `#171412` |
| `surfaceVariant` | `#1F1C1A` |
| `onSurface` | `#F5F5F4` |
| `onSurfaceMuted` | `#A8A29E` |
| `primary` | `#60A5FA` |
| `success` | `#4ADE80` |
| `warning` | `#FBBF24` |
| `danger` | `#F87171` |
| `info` | `#22D3EE` |
| `border` | `#292524` |

**Status color rules:** green = healthy, amber = degraded/warning, red = error/critical, gray = offline/unknown. Never use blue for status (reserved for interactive/accent).

**Contrast:** all text vs. background ≥ WCAG AA (4.5:1 body, 3:1 large). Automated checks in CI.

## 3. Typography

- **Family:** system stack (`-apple-system` / `SF Pro` on iOS, `Roboto` on Android) for native feel and zero download weight. Monospace: `Roboto Mono` / `SF Mono` fallback to `monospace` for terminal & logs.
- **Scale (Flutter `TextTheme`):**

| Role | Size | Weight | Use |
|------|------|--------|-----|
| Display | 34 | SemiBold | Welcome/empty states |
| H1 | 28 | SemiBold | Screen titles |
| H2 | 22 | SemiBold | Section headers |
| H3 | 17 | SemiBold | Card titles |
| Body | 16 | Regular | Body |
| BodySmall | 14 | Regular | Secondary, captions |
| Label | 13 | Medium | Buttons, chips |
| Metric | 20–32 | Bold | Numeric dashboard values (tabular-nums) |
| Mono | 13 | Regular | Terminal, logs, fingerprints |

- **Numbers:** use `tabular-nums` so metrics don't jitter.
- **Scale:** text sizes adjustable 100–125% in Settings (accessibility).

## 4. Spacing & layout

- **Base unit:** 4dp. Scale: `4, 8, 12, 16, 24, 32, 48`.
- **Screen gutters:** 16dp; card padding 16dp; card radius 16dp; sheet radius 20dp top.
- **Section spacing:** 24dp between groups.
- **Grid:** 4-column (narrow phones) to 8-column guidance; content max-width not required on phone.

## 5. Components

### 5.1 Cards
- Server card: status dot, name, 2–4 key metrics (CPU, RAM, disk, temp), uptime, tap → detail.
- Surface `surface`, radius 16, hairline border, subtle shadow (light) / elevation (dark).
- States: default / pressed (scale 0.98) / disabled (60% opacity) / selected (primary border).

### 5.2 Buttons
| Variant | Use |
|---------|-----|
| Primary (filled) | Main action |
| Secondary (tonal) | Alternative action |
| Outlined | Secondary on surfaces |
| Text | Tertiary / inline |
| Destructive | Danger action (filled danger or outlined with danger text) |
| Icon | Compact actions (48×48 tap target) |

Heights: 48dp standard, 40dp compact. Disabled = 60% opacity + no pointer.

### 5.3 Forms
- Labels above fields (13 medium), field height 52dp, radius 12, `surfaceVariant` fill, focus ring `primary`.
- Inline validation: error text below field + red border; success checkmark where helpful.
- One primary CTA per form; keyboard type matches input (URL, number, etc.).

### 5.4 Navigation
- Bottom nav: 3 tabs, 64dp, selected = icon + label tinted `primary`; unselected = muted.
- App bars: title left-aligned; contextual actions right.
- Back: system back + visible back arrow on pushed screens.

### 5.5 Chips & filters
- Filter chips (All/Running/Stopped), 32dp height, rounded-full, selectable state with `primary` fill.

### 5.6 Sheets & dialogs
- **Action confirmations** use bottom sheets (thumb-friendly).
- **Destructive confirm** requires typing the resource name (kill/remove).
- Alerts/errors use toast + optional detail sheet.

### 5.7 List rows
- 64dp rows with avatar/icon, title, subtitle, trailing (status chip / chevron).

## 6. Animations & motion

- **Duration:** micro (100ms press), standard (200–250ms screen), slow (300ms sheets).
- **Easing:** `easeOutCubic` for entrances, `easeInOut` for states.
- **Transitions:** push = platform default; sheets = slide-up; tab switch = 150ms fade.
- **Live data:** metric changes animate via implicit `AnimatedContainer`/tween, capped to avoid strobe; never animate streaming logs (except scroll anchoring).
- **Reduce motion:** honor OS "reduce motion" — disable nonessential animation.
- **Progress:** indeterminate spinner only where duration unknown; linear progress in logs; skeleton shimmer for initial dashboard load (≤ 500ms before showing skeleton).

## 7. Loading states

| Context | Treatment |
|---------|-----------|
| Initial dashboard | Skeleton cards (shimmer) |
| In-place refresh | Pull-to-refresh + subtle progress |
| Stream (metrics/logs) | Live indicator dot + "Live" label |
| Action in flight (restart) | Button shows inline spinner, disabled |
| Page navigation | 200ms standard transition; no full-screen spinner unless >300ms |

## 8. Error states

- **Inline field errors** — message under field.
- **Toast/snackbar** — transient action failures ("Couldn't restart 'db'"), with [Details] affordance.
- **Full-screen error** — illustration + message + [Retry] (connection lost, auth expired).
- **Empty states** — illustration + headline + primary CTA (e.g., "No servers yet").
- Never display raw exceptions; always actionable copy. Provide "Copy error" for support.

## 9. Success states

- Transient: snackbar with check + short message ("db restarted ✓").
- Persistent: status chips green, toast no more than 3s, action buttons return to idle.

## 10. Empty states

| Context | Copy | CTA |
|---------|------|-----|
| No servers | "Add your first server to get started" | [Add Server] |
| No alerts | "All quiet. We'll alert you when something needs attention." | (none) |
| No logs | "No log output yet." | (none) |
| Empty directory | "This folder is empty." | [Upload] |

## 11. Accessibility

- Touch targets ≥ 48×48dp (40dp only for dense icon rows with 8dp spacing).
- Contrast AA throughout (CI-checked).
- Semantic labels on all icons; terminal/log text exposed to screen readers in summary form (per-row live text off to avoid flooding — provide "copy log" action).
- Text scaling 100–125% reflows without breakage.
- Focus indicators visible on Android.
- Status is never communicated by color alone (icons/labels accompany).

## 12. Dark & light mode

- Both fully supported; default = system.
- All tokens dual-defined; third-party packages (charts, terminal) themed accordingly.
- Dynamic color (Material You) support `[NTH — v1.1]`.

## 13. Design deliverables

- Token source: `app/lib/ui/theme/` (Flutter) mirroring this document.
- Component inventory in code (widgets library) reviewed against this spec in PR review.
- Design QA checklist attached to every milestone: contrast, spacing, both themes, a11y, reduced motion.
