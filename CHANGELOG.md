# Changelog

All notable changes to this plugin are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
