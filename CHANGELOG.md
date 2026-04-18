# Changelog

All notable changes to this plugin are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added — auto-invocation for nervous newcomers

Three-layer onboarding so users don't need to know any slash commands:

- **SessionStart hook** (`hooks/welcome.sh`) — fires once on first-run after install. Writes context into Claude's session that instructs it to proactively greet the user, set expectations, and offer a guided walkthrough. Subsequent sessions are silent. Marker stored at `${CLAUDE_PLUGIN_DATA}/.first_run_seen`.
- **Auto-invocable `/start` skill** — removed `disable-model-invocation: true` so Claude can trigger `/start` when a user types newcomer-sounding things in plain language ("I just installed this — what do I do?", "help me migrate my site", etc.). Description expanded to match more natural phrasings.
- **README reframing** — quickstart leads with natural-language examples, not slash commands. Slash command syntax documented as a fallback for power users.

All other skills (`/migrate-site`, `/audit-site`, etc.) remain user-invocable only — auto-firing destructive or expensive skills without explicit consent is bad UX.

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
