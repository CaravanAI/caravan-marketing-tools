# Changelog

All notable changes to this plugin are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
