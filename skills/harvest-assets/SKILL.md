---
name: harvest-assets
description: Download every image and brand asset from a live website with scroll-to-bottom lazy-load catching and self-verified coverage. Use when you need to grab all images from an existing site without doing a full rebuild.
disable-model-invocation: true
argument-hint: "<source-url> [output-dir]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent
---

# Harvest Assets

Download every image, logo, and CSS background from $ARGUMENTS[0] to $ARGUMENTS[1] (defaults to `./public/images/`).

## Phase 0 — Sitemap

Get the URL list (same as other skills):

```bash
curl -s <source-url>/sitemap.xml | grep -oE "<loc>[^<]+</loc>" | sed 's/<[^>]*>//g' | sort -u
```

## Spawn the asset-harvester

Spawn the `asset-harvester` subagent. Pass it the URL list and the output directory. It will:

1. Navigate each URL with Playwright
2. Scroll to bottom before extracting (critical — lazy-loaded images would otherwise be missed)
3. Extract all `<img>` srcs + CSS `background-image` URLs + inline SVG logos
4. Categorize by context: `logo/`, `hero/`, `events/` (or other content-type folders), `team/`, `press/`, `misc/`
5. Track per-element texture application (don't just capture textures — track which element each is applied to)
6. Download in parallel via `curl` with descriptive filenames
7. Generate `manifest.json` mapping old URL → local path + alt text + dimensions
8. Self-verify coverage: re-walk each page, check every URL has a local file, retry failures once, report per-page coverage %

## Final output

Report back with:
- Total URLs scraped
- Total assets downloaded (with category breakdown)
- Coverage % per page
- Any URLs that failed to download (with reason)
- Pointer to `manifest.json` + coverage report

If coverage is below 95%, flag the gap and offer to investigate.

## Rules

- Never declare done without running self-verification
- Always scroll before extracting
- Track per-element texture application in the manifest (lesson: site textures are rarely applied to a single element)
- Filter images < 50×50 (tracking pixels) and obvious Webflow placeholder SVGs
