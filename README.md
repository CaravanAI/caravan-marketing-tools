# Own Your Site

**Your website. Your voice. Your pace.**

A Claude Code plugin that migrates any Webflow, Squarespace, or Wix site to a self-owned Astro project — with one command. Sitemap-first discovery, comprehensive asset harvest, and a visual fidelity check so nothing gets missed.

---

## What it does

Point it at your current website. The plugin:

1. **Reads the sitemap** to find every URL on the site (no page gets missed)
2. **Audits every page** — brand tokens, components, motion, layouts
3. **Downloads every image** with scroll-to-bottom lazy-load catching + self-verification
4. **Scaffolds a new Astro project** with your brand colors, fonts, and content
5. **Checks visual fidelity** — compares your new site to the old one section-by-section
6. **Hands you a localhost preview** you can run, edit, and deploy to Vercel

Then it's yours. Forever. Edit it in plain English with Claude Code. No more agency contracts, no more waiting on changes.

---

## Install

```bash
# Inside Claude Code:
/plugin install own-your-site@caravan-plugins
```

Or install the plugin directly:

```bash
/plugin install own-your-site@https://github.com/CaravanAI/own-your-site
```

**Prerequisite:** Playwright MCP (install separately):

```bash
/plugin install playwright@anthropic
```

---

## Quick start

```bash
# In Claude Code:
/own-your-site:migrate-site https://mybusiness.com
```

That's the whole thing. The plugin walks through discovery → audit → harvest → scaffold → fidelity check → dev server. Takes 20-60 minutes depending on site size. You end up at `localhost:4321` looking at your new site.

---

## What's included

### Skills (user commands)

| Skill | What it does |
|---|---|
| `/own-your-site:migrate-site <url>` | Full end-to-end migration. Flagship command. |
| `/own-your-site:audit-site <url>` | Just the analysis pass. No rebuild. |
| `/own-your-site:harvest-assets <url>` | Just download every image with self-verification. |
| `/own-your-site:check-fidelity <src> <rebuild>` | Compare your rebuild to the source site, section-by-section. |
| `/own-your-site:scaffold-astro <output>` | Create an Astro + Tailwind + Preline project from brand tokens. |

### Subagents (specialized workers)

- **site-scout** — drives Playwright through every page, captures structure + tokens
- **brand-analyst** — extracts design system (colors, type, buttons, spacing)
- **component-analyst** — maps recurring patterns to Preline UI blocks
- **rebuild-architect** — proposes Astro architecture (pages, components, forms, tracking)
- **asset-harvester** — downloads every image with self-verification
- **visual-qa** — side-by-side fidelity diff between source and rebuild

### Docs

Full playbooks live in `docs/`:

- `asset-audit.md` — the sitemap-first harvest pattern
- `scout-and-analysts.md` — the 2-phase agent architecture
- `component-polish.md` — motion + interaction standards (no pausing marquees, no silent placeholders)
- `fidelity-check.md` — 3-phase source→rebuild parity verification
- `modernization-pass.md` — future "modernized" refresh on top of a faithful rebuild

---

## How it works (architecture)

```
/migrate-site <url>
     │
     ▼
sitemap.xml → URL task list  (Phase 0 — never miss a page)
     │
     ▼
site-scout agent             (serial — 1 browser session, all URLs)
     │
     ▼
┌────────┬─────────────┬────────────────┐  (parallel — 3 analysts)
brand    component      rebuild
analyst  analyst        architect
└────────┴─────────────┴────────────────┘
     │
     ▼
asset-harvester              (downloads + self-verifies coverage)
     │
     ▼
scaffold-astro               (creates the new project)
     │
     ▼
visual-qa                    (section-by-section fidelity diff)
     │
     ▼
localhost:4321 + coverage report
```

**Why sitemap-first:** on our pilot migration, the site owner estimated 7 pages. The sitemap revealed 75. That's a 90% miss rate with any other discovery approach.

**Why self-verification:** downloading images isn't enough. The plugin greps your new site for `IMAGE NEEDED` placeholders before declaring it done. No gradient-that-looks-polished-but-is-actually-a-TODO slipping through.

---

## Requirements

- Claude Code (latest version, with `/plugin` support)
- Node.js ≥ 22.12 (for running the generated Astro site)
- Playwright MCP (installed separately — see above)
- A terminal and a few minutes

---

## Contributing

Found a gap in coverage? A site pattern the plugin doesn't handle well? Open an issue or PR. Most of the learnings in this plugin came from real client migrations — yours can too.

See `docs/` for the full playbooks powering each skill. They evolve alongside the plugin.

---

## Built by Caravan

Caravan trains people to do real work with AI — writing, research, marketing ops, design, analysis, and yes, building websites. Our workshops teach you how to delegate the rote parts of your job to Claude and stay in charge of the judgment calls.

Own Your Site is the first plugin in a growing Caravan toolkit for AI-native work. More are coming. Website migration is just the start.

If you want to learn how any of this is actually built, take a Caravan class: [thecaravan.ai](https://www.thecaravan.ai).

---

## License

MIT. Do what you want with it. Build your own agency on top of it. Fork it and make it better. Just keep the license file.
