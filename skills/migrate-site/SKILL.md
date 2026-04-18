---
name: migrate-site
description: Migrate a website from Webflow/Squarespace/Wix to a self-owned Astro project. Runs sitemap discovery, site audit, asset harvest, scaffold, and fidelity check end-to-end. Flagship command. Use when the user wants a full website rebuild.
disable-model-invocation: true
argument-hint: "<source-url> [output-dir]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent
---

# Migrate Site — Flagship Workflow

You are orchestrating a full website migration from $ARGUMENTS[0] to a new Astro project at $ARGUMENTS[1] (defaults to `./new-site/` if not provided).

Read the plugin-level `CLAUDE.md` for the 10 core principles before you start. All of them apply. The `docs/` folder has full playbooks for every phase.

## Phase 0 — Sitemap discovery

**Always start here.** Fetch the sitemap:

```bash
curl -s <source-url>/sitemap.xml | grep -oE "<loc>[^<]+</loc>" | sed 's/<[^>]*>//g' | sort -u > sitemap-urls.txt
wc -l sitemap-urls.txt
```

Read the output. Surface any anomalies *now* to the user:
- Domain mismatches (URLs in sitemap point to a different domain than the site)
- Obvious leftover CMS template pages (`/product/*`, `/category/design`, `/checkout` on non-commerce sites)
- Unexpectedly large counts (if the user estimated 10 pages and the sitemap has 75, tell them)

Wait for the user to confirm scope before proceeding. On a large site, offer to scope down before harvesting everything.

If no sitemap.xml exists, fall back to crawling nav + footer. Warn the user that coverage may be incomplete.

## Phase 1 — Scout

Spawn the `site-scout` subagent via the Agent tool. Pass it the sitemap URL list and the output directory. It will:
- Navigate each URL with Playwright
- Scroll to bottom (catch lazy-loaded images)
- Screenshot desktop + mobile
- Extract brand tokens, images, CSS backgrounds, motion data
- Save raw output to `<output-dir>/audit/`

Wait for scout to complete before moving on.

## Phase 2 — Analysts (parallel)

Spawn THREE subagents in a single message (must be parallel, not sequential):
- `brand-analyst` → produces `audit/01-brand-system.md`
- `component-analyst` → produces `audit/02-component-inventory.md`
- `rebuild-architect` → produces `audit/03-rebuild-plan.md`

All three read the scout's saved output. They don't depend on each other. Wait for all three to finish.

## Phase 3 — Asset harvest

Spawn the `asset-harvester` subagent. It downloads every image from the site with scroll-to-bottom + self-verification. Coverage report goes to `audit/asset-coverage-report.md`. If coverage is < 95%, flag the gap.

## Phase 4 — Scaffold

Invoke the `scaffold-astro` skill with the brand tokens from `audit/01-brand-system.md`. This creates the Astro project at the output directory.

Run `npm install` and start `npm run dev` in the background. Report the localhost URL.

## Phase 5 — Fidelity check

Spawn the `visual-qa` subagent to compare the rebuild (localhost URL) against the source URL. It produces `audit/fidelity-report.md` with per-section divergences and severity tags.

If any critical-severity divergences exist, offer to iterate fixes. Otherwise, mark the migration as ready for client review.

## Final output

Tell the user:
- Total URLs discovered vs migrated
- Total assets downloaded
- Coverage %
- Fidelity report verdict
- Localhost preview URL
- What's still placeholder (note which files have `IMAGE NEEDED`)
- Next steps: review locally → fix any gaps → deploy to Vercel

Run the pre-launch grep checks and report zero hits:

```bash
grep -rn "IMAGE NEEDED" <output-dir>/src/
curl -s http://localhost:4321/ | grep -c "IMAGE NEEDED"
```

## Tone

Treat the user as creative director, not developer. Report in plain language. Flag decisions you made automatically. Ask for scope calls before long-running steps. The user should feel in control, not railroaded through 5 phases they don't understand.
