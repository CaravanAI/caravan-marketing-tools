# Changelog

All notable changes to this plugin are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] — 2026-06-23

### Added — Operating Principles + a robustness pass

- **`PRINCIPLES.md`** — the operating principles the skills reason from, so the tool handles edge cases on its own instead of needing a human guide (never dead-end · safe-by-default · capture-what-renders · verify-once-per-template · resumable · no time promises · degrade silently · authoritative-sources-win).
- **Never dead-end:** `migrate-site` no longer bounces the user to `/start` when the profile is missing — it proceeds on safe defaults (copy, universal path, scrape brand) and states its assumptions.
- **Asset harvest widened:** the scout records `currentSrc` / `srcset` / lazy `data-src` (not just `img.src`), so responsive, lazy-loaded, and `<picture>` images stop showing up as "IMAGE NEEDED."
- **Fidelity per template:** `visual-qa` checks one representative page per template, not just the homepage.
- **Resumable walk:** the scout skips already-saved pages, so an idle Chrome drop resumes instead of restarting.
- **Private by default:** `launch` creates the GitHub repo `--private` (was `--public`).
- **No time estimates:** removed the audit's day/week timeline; it flags complexity honestly instead of promising a duration.
- **README** rewritten in a clean classic open-source style (badges, quickstart-first); time-to-finish claims removed.

## [1.2.0] — 2026-06-23

### Added — bring your own brand guideline

- `start` now asks whether the user has brand guidelines (logo, exact colors, fonts) as a file or link, and captures it.
- `audit-analyst` reads a provided guideline (PDF/doc via Read, link via WebFetch) and treats it as the **authoritative** brand source — overriding values scraped from the live site, flagging mismatches, and using the official logo.
- `migrate-site` writes the brand tokens into the new project's `CLAUDE.md` `## Design system` block (from the guideline when provided), so Claude's design skill and every future edit stay on-brand.

## [1.1.1] — 2026-06-23

### Changed — intake always uses the AskUserQuestion picker

- `start` now has an explicit rule: ask every question through the AskUserQuestion pop-up (click an option, or "Other" to type your own) — never as plain-text chat questions. Only the site URL is free-text. Makes the intake feel like a tap-to-answer quiz, not an interview.

## [1.1.0] — 2026-06-23

### Added — project board (visible, tracked work)

- After the audit is approved, `migrate-site` stands up a **project board** from the site map + migration milestones (Scaffold → Images → Quality check → Launch) and updates it as each phase completes.
- **Team / Enterprise plans** get a live **board artifact** (kanban that republishes in place as work progresses, styled on-brand from `CLAUDE.md` design tokens). **All other plans** get a `PROJECT.md` checklist in the project folder. Degrades silently to `PROJECT.md` if artifact publishing is unavailable.

## [1.0.0] — 2026-06-23

### Changed — repackaged as a Claude Code plugin + public marketplace

Distribution moves from "download a `starter/` folder" back to an installable plugin, published in Caravan's public **caravan-marketing-tools** marketplace. Same capability, lower friction:

- **Plugin layout** — skills + agents live in `plugins/own-your-site/` with a `plugin.json`; the repo root holds `.claude-plugin/marketplace.json` so users install with `/plugin marketplace add CaravanAI/caravan-marketing-tools` then `/plugin install own-your-site@caravan-marketing-tools`.
- **Namespaced commands** — skills are now `/own-your-site:start`, `/own-your-site:migrate-site`, `/own-your-site:launch`.
- **Retired the `starter/` folder** — one source of truth.
- **`site-scout` is dual-path** — it now prefers **Claude in Chrome** (drives the user's real browser; lowest setup friction) and falls back to **Playwright MCP** for headless/large-site runs.
- **Recommended-permissions snippet** added to the README (plugins can't pre-grant tool permissions).

### Added — auto-invocation for nervous newcomers

Onboarding so users don't need to know any slash commands:

- **First-run SessionStart hook** (`hooks/welcome.sh`) — fires once on the first session after install, greets the user, sets expectations, and offers a guided walkthrough. Silent on every session after. Marker stored at `${CLAUDE_PLUGIN_DATA}/.first_run_seen`.
- **Auto-invocable `start` skill** — Claude triggers it when a user types newcomer-sounding things in plain language ("I just installed this — what do I do?", "help me migrate my site").

All other skills remain user-invocable only — auto-firing expensive skills without explicit consent is bad UX.

## [0.1.0] — 2026-04-17

### Added
- Initial public release
- 5 skills: `/migrate-site`, `/audit-site`, `/harvest-assets`, `/check-fidelity`, `/scaffold-astro`
- 6 subagents: site-scout, brand-analyst, component-analyst, rebuild-architect, asset-harvester, visual-qa
- Sitemap-first migration flow (Phase 0 discovery)
- Scroll-to-bottom asset harvesting with self-verification
- Grep-based placeholder detection (`IMAGE NEEDED` pattern)
- Source-vs-rebuild visual fidelity check
- Docs for all 5 underlying playbooks

### Known limitations
- Astro starter template is a stub; extract a real scaffold in `v0.2.0`
- `/modernize` skill planned but not yet shipped
- Playwright MCP must be installed separately as a dependency
