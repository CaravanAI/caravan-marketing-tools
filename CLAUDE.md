# Own Your Site — Plugin Principles

These principles load whenever a skill or agent in this plugin runs. They're the distilled "constitution" of the plugin — how we make decisions, what quality bar we hold ourselves to, what mistakes we never repeat.

Every skill and subagent should read this as context before doing its job.

---

## Mission

Help any person migrate their website off a hosted CMS (Webflow, Squarespace, Wix) to a self-owned Astro project — with zero coding knowledge. A non-developer should be able to run one command, watch it work, and end up with a site they control, understand, and can maintain themselves.

Ownership, not escape. Empowerment, not replacement.

---

## Core principles

### 1. Sitemap-first (Phase 0 of every migration)

Always fetch `https://SITE/sitemap.xml` first. It's the authoritative list of every URL on the site. Every URL becomes a row in the migration task list. Nothing can be "missed" because the sitemap IS the definition of "the site."

**Anecdote:** on the Bigtime Ministries pilot, the agency estimated 7 pages. The sitemap revealed 75, including 19 staff bio pages, 29 event detail pages, and 10 leftover template pages. Sitemap-first = 90% higher coverage.

### 2. Fidelity check always

Never ship a migration without running `visual-qa` to compare the rebuild against the source, section-by-section. Zero critical divergences = ship. Any divergence = fix or document as intentional.

### 3. No silent placeholders

Every component that could render an image MUST have a fallback with the literal string `IMAGE NEEDED` + a dashed magenta border. Grep for the string in source AND rendered HTML. Zero hits = every slot filled. Silent gradients are forbidden — they look intentional and get forgotten.

### 4. Scroll-to-bottom before scraping

Modern CMS platforms (Webflow, Squarespace, Wix) lazy-load images below the fold. Every page scrape MUST scroll through the full page before extracting. Missed images = wasted time + client frustration.

### 5. Per-element texture application

Sites often apply different background textures to different surfaces (navbar ≠ body ≠ footer ≠ CTA bands). The asset manifest must track WHERE each texture is applied. A single body texture is rarely enough.

### 6. Edge-to-edge card images

When a card has an image on top, the image goes flush to the card's edges. Padding applies only to the text area. This is the near-universal modern pattern. Mirror the source design.

### 7. Continuous marquee motion

Photo marquees, scrolling logo rows, and similar ambient elements should never pause on hover. User scrolling shouldn't freeze the background. Pause-on-hover is for content users are actively reading.

### 8. Buttons need lift + shadow hovers

Every button has at minimum: rest state, hover state with `translateY(-1px)` + elevated shadow, active state with pressed-down shadow. Color-only hovers read as 2018. Tactile feedback makes the tool feel made.

### 9. Source-grep + rendered-grep dual verification

Pre-launch checks are two commands: `grep -rn "IMAGE NEEDED" src/` for source-side linting, and `curl localhost | grep "IMAGE NEEDED"` for rendered-output checks. Zero hits on both = clean.

### 10. No adversarial framing

The plugin helps agencies AND owners. It's not anti-agency software. Frame outputs around ownership, empowerment, and self-service — not "escape" or "free yourself from" language. Tasteful positioning builds a bigger tent.

---

## Architecture patterns

### Scout + parallel analysts

Complex audits follow this shape:
- **Phase 1 (serial):** one scout agent drives Playwright through all URLs, saves raw output to disk
- **Phase 2 (parallel):** N analyst agents read the scout's saved files simultaneously, each producing one deliverable

This keeps the main thread clean and dramatically speeds up multi-deliverable work. See `docs/scout-and-analysts.md`.

### Self-verifying harvests

Downloading assets isn't enough. After download, re-walk the source to confirm every URL has a local file. Report coverage %. Retry failures once. See `docs/asset-audit.md`.

### 3-phase fidelity

Rebuild parity comes from:
1. **Pre-build:** scout extracts detailed per-component specs (not just high-level description)
2. **Mid-build:** specs become checklists for component implementation
3. **Post-build:** visual-qa agent produces a divergence report

See `docs/fidelity-check.md`.

---

## What this plugin does NOT do

- **Does not scrape authenticated content.** Only public pages.
- **Does not migrate backends.** If the source site has custom server logic, that's out of scope.
- **Does not auto-deploy.** Generates a local preview. Deploy is a separate step.
- **Does not modernize designs by default.** The faithful rebuild mirrors the source. Modernization is a separate pass (`/own-your-site:modernize` — future).
- **Does not replace designers or agencies.** It automates the rote work so humans can focus on judgment, taste, and strategy.

---

## When in doubt

Read the relevant playbook in `docs/`. If the playbook doesn't answer it, the honest thing is to flag the uncertainty back to the user rather than making a confident guess. The plugin's credibility depends on being right, not on being confident.
