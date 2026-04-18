# Component Polish & Interaction Standards

Durable design standards for migrations. If a future Claude Code session builds a component without consulting this, it will regress into 2018-era hover behaviors, pausing marquees, and invisible placeholders. Read this first.

---

## Ambient motion (marquees, scrolling logos, tickers)

- **Continuous motion.** Never pause on hover. The user scrolling down shouldn't freeze the background.
  - ❌ Don't: `.marquee:hover .row { animation-play-state: paused }`
  - ✅ Do: let it run forever. Pause-on-hover is for content users need to read — not ambient imagery.
- **Dual-direction** — alternate scroll direction between rows for visual interest
- **Mask-image fade** on left/right edges so images fade cleanly off the viewport
- **Multiple speeds** across rows — avoid synchronized motion (reads mechanical)
- **Duplicate the content row for seamless loop** — list the items twice side-by-side, animate `translateX` from `0` → `-50%`

---

## Buttons — the LRY signature treatment

Every button must feel alive. Minimum required states:

| State | What changes | Timing |
|-------|-------------|--------|
| Rest | base bg, base shadow (subtle) | — |
| Hover | bg shift + `translateY(-1px)` + elevated shadow | 200ms ease |
| Active | `translateY(0)` + tighter shadow | instant feedback |
| Focus | visible focus ring (accessibility) | — |

**Why lift + shadow, not just color swap:** color-only hovers read as 2018. Lift + shadow feels tactile + modern without being gimmicky.

**Exact CSS pattern:**

```css
.btn-primary {
  background-color: var(--color-brand-navy);
  color: white;
  transform: translateY(0);
  box-shadow: 0 1px 2px rgba(16, 19, 46, 0.08);
  transition: background-color 0.2s ease, transform 0.2s ease, box-shadow 0.2s ease;
}
.btn-primary:hover {
  background-color: #050820;           /* slightly darker than base */
  transform: translateY(-1px);
  box-shadow: 0 6px 14px rgba(16, 19, 46, 0.22);
}
.btn-primary:active {
  transform: translateY(0);
  box-shadow: 0 1px 2px rgba(16, 19, 46, 0.12);
}
```

Secondary/outlined buttons: same lift pattern, bg fills with accent color on hover.

---

## Missing-asset placeholders — the grep-able standard

Every component that takes an image MUST have a fallback placeholder that:

1. **Uses dashed border + accent color** — looks visibly unfinished
2. **Says "IMAGE NEEDED"** in uppercase, letter-spaced, bold — readable instantly
3. **Shows subject context** — the card's title, the row's heading, etc.
4. **Contains the literal string `IMAGE NEEDED`** in source + rendered HTML so self-check grep works

**Why:** silent placeholders (gradients, blank boxes) look intentional and get forgotten. Loud placeholders can't survive a review.

See `asset-audit.md § Target-Side Verification` for the full grep-based self-check.

---

## Arrow links (inline "Learn More →" style)

- Small inline arrow glyph (SVG, 18px)
- **Gap widens on hover** (6-8px → 10-12px) — subtle directional feel
- Color shift on hover (primary accent → secondary accent)
- No underline

```css
.arrow-link {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: var(--accent);
  transition: color 0.2s, gap 0.2s;
}
.arrow-link:hover {
  color: var(--accent-secondary);
  gap: 12px;
}
```

---

## Card image handling — edge-to-edge by default

When a card has an image on top, the image goes **flush to the card's edges** — padding applies only to the text area below, not to the image. This is the near-universal pattern on modern sites (Webflow, Squarespace, custom).

- ❌ Wrong: `<div class="p-8"> <img class="w-full ..." /> <h3>...</h3> </div>` — image inherits the card's padding, leaves visible whitespace on sides of the image
- ✅ Right: `<div class="overflow-hidden"> <img class="w-full ..." /> <div class="p-8"> <h3>...</h3> </div> </div>` — image fills card width, text wrapper carries padding

**Exception:** some editorial / art-direction cards intentionally frame the image with whitespace. Follow the source design's treatment — this rule isn't universal, it's the common case. If in doubt, mirror what the client's live site does.

---

## Card hover states

- **Slight lift** (`translateY(-2px)`)
- **Elevated shadow** (`0 12px 24px rgba(0,0,0,0.08)`)
- **Image zoom inside** (`img { transition: transform 400ms ease; }` + `.card:hover img { transform: scale(1.03); }`)
- 250-300ms transition — slightly longer than buttons
- Avoid: rotation, color inversion, dramatic scale changes. Reads as "look at me."

---

## Mobile responsive rules (inherited from Caravan)

- **Image-first on mobile** for text-left-image-right rows: `order-last lg:order-none` on the text column
- **H2 alignment**: `text-left lg:text-center` — left-aligned on mobile, centered on desktop
- **No horizontal overflow**: set `html { overflow-x: hidden }` globally
- **Grid breakpoints**: prefer `grid-cols-1 sm:grid-cols-2 lg:grid-cols-3` over bare `grid-cols-3`
- **Stack CTAs** on mobile (`flex-col sm:flex-row`)

---

## Typography — editorial accents

- **Accent span in H1/H2** — 1-3 words styled differently (italic + brand color) for personality
  - Webflow sites often call this `.is-highlighted-italics` or similar
  - In Astro: a simple `<span class="heading-accent">` utility
- **Font loading via Google Fonts** — preconnect + `<link>` in head + `font-display: swap`
- **Inter / Manrope / Plus Jakarta Sans** for "2026 but timeless" feel (neo-grotesque sans-serifs)
- **Letter-spacing** on headings: `-0.01em` to `-0.03em` (tighter than body). Makes display type feel intentional.

---

## Spacing system (inherit from Caravan / adapt to client rhythm)

| Use | Tailwind | Value |
|-----|----------|-------|
| Section vertical padding | `py-20 lg:py-28` (Caravan) / `py-24 lg:py-32` (LRY — airier) | 80/112 or 96/128 |
| Section header margin-bottom | `mb-12 lg:mb-16` | 48 / 64 |
| Subtext below heading | `mt-6` | 24 |
| CTA above/below header | `mt-8` | 32 |
| Grid card gap | `gap-6` | 24 |
| Image+text row gap | `gap-10 lg:gap-16` | 40 / 64 |

**Max-width buckets:**
- Wide (`max-w-7xl`): hero, testimonials, large grids
- Medium (`max-w-5xl`): alternating rows, editorial H2 pauses
- Narrow (`max-w-3xl`): FAQ accordions, contact copy, final CTA body

---

## What reads as "AI-generated" to avoid

- All-rounded corners when the brand has sharp edges (and vice versa)
- Emoji in H1s or above-the-fold copy
- Generic "Hero → 3-column features → testimonial → CTA" layout with no variation
- Heavy gradient hero backgrounds (blur, mesh)
- Over-use of pastel accents
- Generic stock photography when the client has real photos
- Every card looking identical — zero layout variation

---

## Pre-launch checklist (merge into asset-audit.md's launch checklist)

- [ ] Zero `grep -rn "IMAGE NEEDED" src/` hits
- [ ] Zero rendered placeholder strings in `curl` of every route
- [ ] Every button has hover + active states with `transform` + `box-shadow`
- [ ] Every marquee has continuous motion (no pause on hover)
- [ ] Every card has hover state (lift + shadow + image zoom)
- [ ] Mobile: image-first on alternating rows, left-aligned H2s
- [ ] Fonts loaded via Google Fonts preconnect + link
- [ ] No `#` hrefs anywhere (broken nav items)
- [ ] No Lorem ipsum
- [ ] All `<img>` URLs resolve (zero 404s in dev console)

---

## Background textures — capture AND apply them per element

Webflow / Squarespace / Wix sites often apply different textured backgrounds to different elements (navbar vs body vs footer vs CTA bands). A naïve scrape pulls the image files but doesn't tell you *where* each one is applied. Result: you apply one texture to the body and miss that the navbar uses a different one.

**Capture strategy:** during scraping, note the CSS selector each texture is applied to. The asset manifest should track:
```json
{
  "local": "misc/bg-texture-plain.jpeg",
  "applied_to": "<header> / navbar2_component",
  "role": "navbar surface"
}
```

**Common texture slots seen in Webflow builds:**
- Navbar surface
- Main page canvas (body)
- Footer (often on dark background)
- CTA bands (purple / colored variants)
- Card surfaces inside panels

**Ship rule:** a single body texture is insufficient for brands that use multiple. Apply each texture to its specific element explicitly. Inline `style="background-image: url(...)"` is fine — don't over-engineer with Tailwind utilities for a ~5-element mapping.

---

## Why this doc exists

On the LRY pilot (2026-04-16), I shipped multiple iterations of the homepage before Robert spotted:
1. Marquee paused when he scrolled (because of a `:hover` pause I put in out of habit)
2. Buttons had no hover animation (just color transitions)
3. 6 category cards had gradient placeholders that looked intentional enough to be forgotten
4. Navbar was missing its textured background (applied only to body, not per-element)
5. Category card images had padding around them instead of going edge-to-edge like the source site

Each one wasted a round-trip. All five are now captured here as durable standards. Future Claude Code sessions: use this doc as a ship checklist before declaring a page done.
