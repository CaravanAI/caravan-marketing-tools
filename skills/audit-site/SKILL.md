---
name: audit-site
description: Audit an existing website without rebuilding. Runs sitemap discovery, scout agent, and three analyst agents in parallel. Produces audit docs (brand system, component inventory, rebuild plan). Use when evaluating a site before committing to a full migration.
disable-model-invocation: true
argument-hint: "<source-url> [output-dir]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent
---

# Audit Site

You are running the discovery + audit phases of a migration WITHOUT rebuilding. This is for evaluating a site before committing to full migration, or for producing audit docs a client meeting can reference.

Target: $ARGUMENTS[0]
Output: $ARGUMENTS[1] (defaults to `./audit/`)

## Phase 0 — Sitemap

```bash
curl -s <source-url>/sitemap.xml | grep -oE "<loc>[^<]+</loc>" | sed 's/<[^>]*>//g' | sort -u > <output-dir>/sitemap-urls.txt
wc -l <output-dir>/sitemap-urls.txt
```

Report URL count. Flag anomalies (see migrate-site skill for specifics).

## Phase 1 — Scout

Spawn `site-scout` subagent. Output goes to `<output-dir>/screenshots/` and `<output-dir>/data/`. Scout writes `<output-dir>/scout-findings.md` as a summary.

## Phase 2 — Analysts (parallel)

Spawn 3 subagents in one message:
- `brand-analyst` → `<output-dir>/01-brand-system.md`
- `component-analyst` → `<output-dir>/02-component-inventory.md`
- `rebuild-architect` → `<output-dir>/03-rebuild-plan.md`

## Final output

Report back with:
- Sitemap URL count + anomalies flagged
- Scout findings summary
- Pointer to the 3 analyst docs
- Rough timeline estimate for the full rebuild (from `03-rebuild-plan.md`)
- Any major scope concerns worth discussing before committing to a rebuild

Do NOT scaffold, harvest assets, or run a fidelity check. Those phases belong to `/migrate-site`. Stay focused on the audit.
