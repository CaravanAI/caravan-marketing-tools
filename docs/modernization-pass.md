# Modernization Pass Playbook (concept — not yet built)

## The idea

After a faithful rebuild (which mirrors the client's current Webflow design), run a second agent pass that proposes a **2026-design-standard refresh** while preserving the brand's DNA. Deliver both versions side-by-side so the client can see:

1. **The current site, rebuilt in Astro** — same design, new tech, actual web fonts, cleaner code
2. **The "modernized" version** — same brand (colors, typography, voice), same content, thoughtfully upgraded layout + motion + typography + spacing

The client picks which one to ship. Or adopts bits from both.

## Why it matters

Most small-business sites were designed 3-7 years ago in Webflow / Squarespace / Wix. The brand is often still fresh, but the layout patterns (giant hero → three columns of features → mid-page testimonial → footer) have aged. A migration is a natural moment to offer a design refresh — but clients usually balk at "throw it all out." Showing both versions makes the refresh feel like a menu, not a cliff.

## Positioning

- **Not AI-looking.** No generic rounded corners everywhere, no gradient-heavy hero with blur, no emoji in the H1, no "vibe" layouts. Modern means considered, not generated.
- **Brand-preserving.** Same colors, same fonts (or a tasteful upgrade to a related typeface), same voice, same imagery. The client's identity isn't up for debate.
- **Layout + motion + hierarchy only.** What changes: composition of sections, interaction affordances (button hovers, scroll reveals, hover states on cards), use of whitespace, editorial treatments of headlines, mobile density. What doesn't change: information architecture, brand system, photography.

## How it would work

1. **Start from the faithful rebuild** — Astro components, brand tokens, all content wired in
2. **Spawn a "modernization agent"** with explicit guidance:
   - Preserve brand tokens unchanged
   - Redesign layout composition per section (different hero treatment, reframed testimonial, richer case study cards, etc.)
   - Apply 2026 design standards: generous whitespace, editorial typography, subtle motion, aspirational imagery framing, thoughtful hover states
   - Output components with suffix `-modernized.astro` (e.g., `HomeHero-modernized.astro`)
3. **Add a toggle** — a single route (`/preview/modernized`) or a toggle control that swaps the component set
4. **Client review** — share two URLs side-by-side; ask which direction they want to take (or take bits from both)

## Concrete design moves that read as "2026" (not AI)

- Oversized, editorial H1 typography with selective italic accents for personality (LRY already uses this pattern — lean into it harder)
- Asymmetric grid layouts for content sections (one wide column + narrow sidebar vs rigid 50/50)
- Subtle scroll-triggered reveals on key content (fade + slight rise), not parallax
- Richer hover states on cards (lift + shadow + image zoom, not just opacity fade)
- Use of client photography as full-bleed moments between sections, not only in hero
- Pair classic sans with a tight serif or monospace for accents in specific spots (pull quotes, metadata)
- Generous mobile density — don't just stack everything, re-compose for small screens
- Sharp rectangles and hard edges where the brand has that personality (LRY), soft curves where it doesn't
- Real motion on buttons (lift + color transition, not just background swap)
- Editorial image captions / metadata that feel like print design

## What not to do

- Don't swap the client's font for something "trendy"
- Don't introduce new accent colors
- Don't add emoji
- Don't use Geist / Satoshi / other heavily over-used AI-era fonts unless they genuinely fit
- Don't blur-heavy hero backgrounds
- Don't auto-generate stock photography
- Don't rewrite the copy — that's a separate engagement

## Required before implementation

- **Design reference library** — 20-30 websites that represent "modern but timeless" for different industries (event agency, SaaS, consumer brand, professional services)
- **Style transfer rules** — what changes, what stays
- **Reviewer checklist** — signals that the output is landing in "AI-generated" territory (too many gradients, every card looks identical, generic hero layout) vs intentional-design territory

## Pilot candidate

Run this pass on LRY after the faithful rebuild is signed off by the client. LRY's site is a great candidate because:
- Strong brand (navy + magenta + rectangles) that's worth preserving
- Dense content (24 case studies, team, services, press) that benefits from better hierarchy
- Event-agency category naturally rewards richer motion + photography treatments
- Client trust already exists (shared Birmingham address) so the "experimental modernized version" conversation is low-risk

## Status

**Concept only.** Not built yet. Budget: ~1-2 sessions of work per client after faithful rebuild lands. Document learnings here as we build it.
