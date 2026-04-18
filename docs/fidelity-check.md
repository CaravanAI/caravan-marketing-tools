# Fidelity Check Playbook

How to prevent the "miss → correct → miss again" cycle on migrations. The goal: **near 1:1 visual parity** between the source site and the rebuild, verified programmatically instead of by eyeballing.

This is the third leg of the scrape triangle:
- `asset-audit.md` — get every asset
- `component-polish.md` — apply interaction standards
- `fidelity-check.md` — verify the rebuild actually matches the source **(this doc)**

---

## The three phases

### Phase 1 — Pre-build: detailed component spec extraction

When the scout does its initial site audit, most implementations stop at "here are the recurring patterns, here are the brand tokens." That's too high-level. The rebuild agent then fills in gaps by guessing.

**Upgrade:** the scout extracts a detailed spec per recurring component, capturing:

- **Layout:** container width, inner padding, grid columns at each breakpoint, gap between items
- **Image handling:** edge-to-edge vs padded, aspect ratio, object-fit, alt-text pattern
- **Typography:** exact font-family, font-size, font-weight, line-height, letter-spacing, color per role (heading, body, label, caption)
- **Background:** color, image (if texture), repeat mode
- **Borders / corners:** border-radius, border-width, border-color
- **Hover / interaction state** (when available): transform, box-shadow, color change, transition duration
- **Spacing between sections:** the padding-top / padding-bottom of each containing section

**Example spec entry:**

```json
{
  "component": "ClientCategoriesGrid",
  "source_selector": ".section_layout395 .layout395_card",
  "layout": {
    "columns": { "base": 1, "sm": 2, "lg": 3 },
    "gap": "24px",
    "max_width": "1152px"
  },
  "card": {
    "background": "#ffffff",
    "border_radius": "0",
    "padding": "0",
    "image_edge_to_edge": true
  },
  "image": {
    "aspect_ratio": "3/2 approx",
    "height": "192px",
    "object_fit": "cover",
    "position": "top flush"
  },
  "text_wrapper": {
    "padding": "32px"
  },
  "heading": {
    "font_family": "Helvetica, sans-serif",
    "font_size": "20px",
    "font_weight": "700",
    "color": "#10132e"
  }
}
```

This becomes the source of truth. The rebuild doesn't guess — it reads the spec.

**How to extract it:** `browser_evaluate` with a per-component function that hits known selectors and returns computed styles. See agent prompt template below.

### Phase 2 — Mid-build: spec-as-checklist

Each component in the rebuild has a corresponding spec block. Before the component is marked done:

1. Open the spec
2. For each spec property, verify the rebuild implements it
3. Mark unchecked items → fix, recheck, repeat

This sounds manual. It can be automated: a simple `verify-component.ts` script that reads the spec JSON + the rebuild's rendered output, compares the two, and reports diffs.

### Phase 3 — Post-build: visual QA agent (side-by-side diff)

The capstone check. A dedicated agent:

1. Navigates to the source site at a standard viewport (1440×900 desktop + 390×844 mobile)
2. Takes screenshots at 8-12 key scroll positions (one per major section)
3. Navigates to the rebuild at `http://localhost:[port]`
4. Takes matching screenshots
5. For each section: extracts computed CSS on the primary container + heading + image + buttons
6. Produces a `fidelity-report.md` with:
   - **Screenshot pairs** (source vs rebuild) for each section
   - **Divergences list:** every place the rebuild diverges from spec by > 5% on numerical values or any categorical mismatch
   - **Severity tags:** critical (visibly wrong) / moderate (layout off) / minor (typography weight differs)
   - **Recommended fixes** per divergence

Run this agent **before declaring any page done**. Zero critical-severity divergences = ship. Any critical = fix and re-run.

---

## The visual QA agent prompt

Reusable template — swap the section list + URLs per client.

```
You are the VISUAL QA AGENT. Compare <rebuild URL> against <source URL> and produce a structured divergence report.

## Setup
Load Playwright tools: select:mcp__plugin_playwright_playwright__browser_navigate,...

## Viewport
Start at 1440×900 desktop. After desktop pass, repeat at 390×844 mobile.

## Sections to compare
[List the sections by their identifying text or class]
- Navbar
- Hero
- [Section 2]
- [Section 3]
- ...

## Per-section procedure

For each section:
1. Navigate to source URL, scroll to section via heading text or class
2. Screenshot section (use element screenshot or viewport clip at known scroll position)
3. browser_evaluate to extract from the primary container:
   - outer dimensions (width, height)
   - padding + margin
   - background (color, image URL if any)
   - first-child typography (font family, size, weight, color)
   - image object-fit + aspect ratio (if image present)
   - hover transform (if interactive)
4. Repeat on rebuild URL
5. Diff the two:
   - Numerical values: flag any > 5% divergence
   - Categorical (font family, color, image URL): flag any mismatch
   - Boolean (edge-to-edge image, has-texture): flag any mismatch

## Output
Write to audit/fidelity-report.md:
- Summary: sections matching / sections with divergences
- Per section: side-by-side screenshot paths, matches list, divergences list (with severity), recommended fix
- Total severity breakdown: N critical, N moderate, N minor

Return a brief summary (~150 words).

## Rules
- Don't modify any source code — report only
- Use filename param on screenshot/evaluate to save to disk
- Skip sections that don't exist in the rebuild yet (mark as "rebuild pending")
```

---

## Why this prevents the cycle

Before: rebuild ships based on scout's high-level summary → reviewer spots gap → fix → reviewer spots next gap → fix → ... each round is serial and wastes attention.

After: rebuild ships against a detailed spec + passes a visual QA check → reviewer only sees the finished version. If the reviewer spots something the QA missed, that gap becomes a new check added to the spec schema. **The feedback loop makes the playbook smarter with every run, not the human.**

---

## What to do when the source and rebuild can't match exactly

Some divergences are intentional or unavoidable:

- **Webflow's own class names** (like `layout395_card`) don't map to your Astro classes — fine, the spec extraction is about visual output not DOM structure
- **Font rendering** differs between Webflow and Astro/Vite — slight anti-aliasing differences are fine, size/weight/family must match
- **Brand improvements** (like actually loading Helvetica web fonts instead of falling back to Arial) are an intentional upgrade — document this, exempt from the fidelity check
- **Accessibility fixes** (higher contrast, better focus states) override pixel parity — document as intentional divergence

Always run the report, always read it, then explicitly approve intentional divergences. That paper trail matters.

---

## Pre-launch fidelity gate

Add to the migration checklist:

- [ ] `audit/fidelity-report.md` generated
- [ ] Zero critical-severity divergences unresolved
- [ ] Intentional divergences documented in the report with rationale
- [ ] Reviewer (Robert) signed off on report

---

## Why this doc exists

LRY pilot, 2026-04-16: five separate "you missed X" corrections in one session:
1. Marquee paused on scroll
2. Buttons had no hover animation
3. Gradient placeholders on category cards
4. Navbar missing texture
5. Category images had padding (should have been edge-to-edge)

Each of these would have been caught by a detailed component spec extracted upfront + a visual QA pass before declaring the page done. With this playbook in place, future migrations don't re-litigate the same five issues — the spec captures the right answers from the source site, the QA verifies the rebuild matches.
