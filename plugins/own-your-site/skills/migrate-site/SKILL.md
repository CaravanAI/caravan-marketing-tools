---
name: migrate-site
description: Migrate a website from Webflow, Squarespace, Wix, or WordPress to a self-owned Astro project. Reads `.own-your-site/notes.md` (from `/own-your-site:start`) for the user's profile, then runs the full migration end-to-end — sitemap discovery, scout pass, audit analysis, asset harvest, scaffold, and fidelity check. Flagship command. Use when the user wants a full website rebuild and the intake interview has already been completed.
argument-hint: "<source-url> [output-dir]"
allowed-tools: Bash Read Write Edit Glob Grep Agent
---

# Migrate Site — Flagship Workflow

You are orchestrating a full website migration from $ARGUMENTS[0] to a new Astro project at $ARGUMENTS[1] (defaults to `./new-site/`).

**Operating principles:** read `${CLAUDE_PLUGIN_ROOT}/PRINCIPLES.md` first and apply it throughout — especially *never dead-end* and *safe-by-default*.

## Phase -1 — Read the user's profile

Read `.own-your-site/notes.md` from the working directory.

- If it exists with `Phase: intake-complete` (or later), use the profile to skip questions you already have answers for.
- If it doesn't exist, **don't dead-end** (Principle 1). Offer a 20-second inline intake if they're up for it; otherwise proceed on safe defaults and say so: approach = *copy* (faithful match), plan = unknown → universal path (nothing premium-gated), brand = none → reverse-engineer from the site, accounts → ask at launch. State the assumptions so they can correct any.

Update `notes.md` to mark `Phase: migration-in-progress` before kicking off Phase 0.

If the user's approach is "redesign", **skip the fidelity check at the end** — it's expected to diverge from the source.

## Phase 0 — CMS detection (verify the profile)

If the profile already has a confirmed platform, skip and use it. Otherwise:

```bash
curl -s <source-url> | grep -oiE "(webflow|squarespace|wixstatic|wp-content|wp-includes|<meta name=\"generator\" content=\"[^\"]+\")" | head -5
```

For WordPress with dynamic features (commerce, members, custom forms), surface a per-feature decision before proceeding. For Webflow / Squarespace / Wix / clean WordPress: standard path.

## Phase 1 — Sitemap

```bash
curl -s <source-url>/sitemap.xml | grep -oE "<loc>[^<]+</loc>" | sed 's/<[^>]*>//g' | sort -u > <output-dir>/audit/sitemap-urls.txt
wc -l <output-dir>/audit/sitemap-urls.txt
```

Surface anomalies *now*: domain mismatches, leftover template pages, unexpectedly large counts. Wait for the user to confirm scope before proceeding. If no sitemap, fall back to crawling nav + footer; warn coverage may be incomplete.

If the user estimated 7 pages and the sitemap has 75, tell them.

## Phase 2 — Scout (data collection)

Spawn the `site-scout` subagent. Pass the sitemap URL list and output directory. It walks every URL with Playwright, captures screenshots, scrolls to trigger lazy-loads, extracts brand tokens, saves all data to `<output-dir>/audit/`.

Wait for scout to complete. If the browser connection drops mid-walk (common on the live-Chrome path), just re-spawn the scout — it resumes from the first page it hasn't saved yet (Principle 5), not from scratch.

## Phase 3 — Audit (analysis)

Spawn the `audit-analyst` subagent. It reads the scout's output and produces ONE complete audit document at `<output-dir>/audit/audit.md` covering:
- Brand system (colors, typography, buttons, spacing)
- Component inventory (Preline matches + custom flags)
- Rebuild plan (site map, component tree, data, forms, tracking, timeline)
- Open scope questions

Show the user the audit before proceeding to scaffold. Let them push back on assumptions.

## Phase 3.5 — Project board (show the plan as tracked work)

Once the audit is approved, stand up a project board so the user can see what's done, in progress, and left — like a real agency would, instead of a black box. Build the task list from the audit's site map (one item per page/template) plus the migration milestones: Scaffold → Images → Quality check → Launch.

Read the plan from `.own-your-site/notes.md` and branch:

- **Team / Enterprise plan → publish a board artifact.** Write a self-contained kanban HTML (columns: To-do / In progress / Done; cards = pages + milestones) and publish it with the Artifact tool. **Republish to the same artifact as each phase finishes** so the board updates in place while they watch (the page can't poll itself — Claude editing + re-publishing is how artifacts update). Pull colors/fonts from the project's `CLAUDE.md` design tokens so it's on-brand. Needs a `/login` session on the Anthropic API (not Bedrock/Vertex/Foundry); Claude asks permission on first publish.
- **Any other plan (Pro / Max / unsure) → write a `PROJECT.md` checklist** in the project folder instead (`## Done` / `## In progress` / `## To do` with `- [ ]` items). Re-show it at each checkpoint. Same information, works everywhere, persists in their repo.

Either way: **update the board as each later phase completes**, and glance at it with the user at each gate. If artifact publishing isn't available for any reason, fall back silently to `PROJECT.md` — never leave the user without a progress view.

## Phase 4 — Scaffold

Run the Astro scaffold inline (no separate subagent — this is straightforward execution):

```bash
cd <output-dir>
npm create astro@latest . -- --template minimal --yes --no-install
npm install -D @astrojs/sitemap @tailwindcss/forms @tailwindcss/typography @tailwindcss/vite tailwindcss preline
```

Wire in from `audit.md`:
- `src/styles/global.css` with `@import "tailwindcss"` + `@theme` block (brand tokens)
- `CLAUDE.md` (in the new project) — a `## Design system` block listing the brand tokens (colors, typography, spacing) from `audit.md`, sourced from the **brand guideline** if one was provided (else the scraped values). This keeps Claude's built-in design skill and every future "change my homepage" edit on-brand.
- `src/layouts/BaseLayout.astro` — font preconnects, slot, **and the SEO head**: per-page `<title>` and `<meta name="description">` (passed as props, defaulting to the audit's per-page metadata), a self-referencing `<link rel="canonical">`, and Open Graph + Twitter-card tags. Every page passes its own title/description through.
- `src/components/StructuredData.astro` — JSON-LD from the audit (Organization always; LocalBusiness if the business has a location/phone/hours), rendered in BaseLayout's `<head>`
- `src/components/Navbar.astro`, `Footer.astro`, `PlaceholderImage.astro` (with `IMAGE NEEDED` literal string + dashed magenta border), `Button.astro`
- **Forms:** wire the *working* backend the audit chose (e.g. Formspree action / HubSpot embed) so the contact form actually submits — never ship dead form markup. It's often the business's #1 conversion.
- `public/robots.txt` — allow crawling + a `Sitemap:` line; confirm no page is left `noindex`
- `astro.config.mjs` — set `site` to the final domain (so the sitemap emits absolute URLs), `@astrojs/sitemap` integration, Tailwind v4 vite plugin
- `vercel.json` — `redirects` (HTTP 301) for every row the audit's URL map flagged as *changed*; if nothing changed, no redirects needed
- `package.json` scripts: `dev`, `build`, `preview`, `verify` (greps for IMAGE NEEDED)

**Migration safety:** the rebuilt pages must live at the **same URL paths** as the source (per the audit's URL map). Same paths = the site keeps its Google ranking with zero redirects. Only the rows flagged as changed get a 301 in `vercel.json`.

**Design-taste decision:** if profile says `Approach: copy`, mirror the source's button/card/marquee behavior even when it's not "modern." If `redesign`, apply lift+shadow buttons, edge-to-edge card images, and continuous marquees as defaults.

## Phase 5 — Asset harvest

Use the scout's saved data (or a fresh pass) to download every image source it recorded — including the `srcset`/`currentSrc` candidates and lazy `data-src` URLs, plus CSS backgrounds (Principle 3) — to `<output-dir>/public/images/` via parallel curl. Self-verify coverage — every recorded source should have a local file. Report % coverage. Retry failures once.

## Phase 6 — Run + fidelity

`npm run dev` in the background. Capture the URL (usually `http://localhost:4321`).

If profile is `copy`: spawn the `visual-qa` subagent to compare rebuild against source — **one representative page per template** (home + one of each distinct layout), not just the homepage (Principle 4). Report critical / moderate / minor divergences. If profile is `redesign`: skip this — divergences are expected.

Run pre-launch grep checks:

```bash
grep -rn "IMAGE NEEDED" <output-dir>/src/
curl -s http://localhost:4321/ | grep -c "IMAGE NEEDED"
```

Both should be zero before declaring done.

Also confirm the SEO basics rendered on the homepage:

```bash
curl -s http://localhost:4321/ | grep -ioE "<title>|rel=\"canonical\"|application/ld\+json" | sort -u
```

Expect `<title>`, a canonical link, and a JSON-LD block. If any are missing, fix BaseLayout/StructuredData before handing off.

## Phase 7 — Hand off

Tell the user, in plain language:

> "Your new website preview is ready. Open **http://localhost:4321** in your browser to see it. A few things to know:
> - It's running **on your computer**, not on the internet. Only you can see it.
> - Your current live website is unchanged — this new site lives in its own folder (`new-site/`, inside the folder you opened Claude Code in). Your existing files weren't touched.
> - You can stop here if you want. Everything is saved to your computer. You can pick back up next week or next month — just open Claude Code in this folder again."

Then summarize:
- Pages migrated, images downloaded, coverage %
- Fidelity verdict (if applicable) or note that divergences are intentional (redesign)
- Any unfilled placeholders
- Next: open the preview, click around, tell me what looks off
- After that: `/own-your-site:launch` to put it online

## Write back to notes

Update `.own-your-site/notes.md`:

```
**Phase:** rebuild-complete
**Pages migrated:** <count>
**Images downloaded:** <count>
**Coverage:** <%>
**Preview URL:** http://localhost:4321
```

## Tone

Treat the user as creative director, not developer. Report in plain language. Flag decisions you made automatically. Ask for scope calls before long-running steps. The user should feel in control, not railroaded through phases they don't understand.

Avoid jargon. "Dev server," "localhost," "scaffold," "render" — any of these need a one-line plain-language version if the user seems new.
