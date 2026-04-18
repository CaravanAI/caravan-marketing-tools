# Asset Audit Playbook

A reusable pattern for comprehensive image harvesting from a live website during migration — with self-verification. First run on LRY (2026-04-16). Designed as a reusable artifact for the open-source Caravan / Uphill Growth migration toolkit.

---

## What this solves

Client agency migrations typically need to pull every image asset off the old site (Webflow, Squarespace, Wix, etc.) and drop them into a new Astro (or any static site) project. Doing this by hand means clicking through dozens of pages and right-click → Save As for every image. This playbook does it with an agent + Playwright in ~20 minutes for most sites.

The critical innovation over a naive "scrape all `<img>` tags" approach: **self-verification**. After download, the agent walks the live site again and checks coverage page-by-page. If a page has 30 images rendered and only 25 got downloaded, it flags the gap.

---

## When to use this

- Any migration from a hosted site builder to your own stack (Webflow/Squarespace/Wix → Astro/Next/etc.)
- Redesigns where you want to keep the client's photography but throw out the HTML
- Backing up a client's visual assets before canceling the old hosting

---

## Expected runtime (set expectations with client)

| Site size | Pages | Agent runtime |
|---|---|---|
| Tiny landing page | 1-3 | 3-7 min |
| Small service business | 4-10 | 7-15 min |
| Typical agency/business w/ portfolio | 10-25 | 15-30 min |
| Large site w/ CMS collections (blog, case studies) | 25-50 | 30-60 min |
| E-commerce / big content sites | 50-100+ | 1-3 hours |
| Enterprise (huge content libraries) | 100+ | Multiple hours |

**Tell the client upfront:** "This isn't an hour job for large sites." Most small-business agency migrations fit in 30 min. Plan accordingly.

---

## Phases

### Phase 0 — Fetch the sitemap (do this first, always)

Before anything else, fetch `https://SITE/sitemap.xml`. This is the site owner's authoritative declaration of every public URL. Parse it, save the URL list, and use it as the migration's task list and coverage source of truth.

```bash
curl -s https://SITE/sitemap.xml | grep -oE "<loc>[^<]+</loc>" | sed 's/<[^>]*>//g' | sort -u > sitemap-urls.txt
wc -l sitemap-urls.txt  # total URLs in the migration scope
```

**Why this matters — lesson from the Bigtime pilot (2026-04-17):**
The agency's initial scope estimate was "about 7 pages" based on eyeballing the nav. The sitemap revealed **75 URLs**, including:
- 19 staff bio pages no one mentioned
- 29 per-event detail pages
- 10 leftover Webflow template pages that were never removed (fake products, ghost categories)
- A **domain misconfiguration** — the sitemap served URLs for `chelseabigtime.com` while the site lived at `bigtimeministries.com`, a significant SEO issue the client didn't know about

Without sitemap-first, the migration would have missed 68 URLs (90% miss rate) AND missed flagging the domain issue.

**What to do with the sitemap:**
- Drop every URL into the migration task list
- Flag anomalies upfront: domain mismatches, template leftovers, URL patterns that shouldn't be indexed
- Use it as the ground-truth coverage report: "X of N URLs scraped / migrated / fidelity-checked"
- Share anomalies with the client in the kickoff meeting — they often don't know about these

**Fallbacks if no sitemap exists:**
- Check `robots.txt` for `Sitemap:` directives
- Crawl the nav + footer recursively for `href`s within the same domain
- For sitemaps listing thousands of URLs (e-commerce), decide scope cuts with the client before scraping (probably don't migrate every product detail page into Astro)

### Phase 1 — Page discovery

Enumerate every URL the audit will visit:
- Crawl the top-level nav + footer (usually 5-10 pages)
- For dynamic collections (blog, portfolio, events, products), visit the index page and extract every `/items/[slug]`, `/posts/[slug]`, `/events/[slug]` href
- For LRY: 8 top-level + 20+ case-study detail pages = ~28 URLs

### Phase 2 — Per-page extraction

For each URL:
1. `browser_navigate` to URL
2. **Scroll through the page** — essential to trigger lazy-loaded images. Walk from `0` to `scrollHeight` in viewport-sized steps with ~250ms waits. End with a scroll to bottom and pause, then scroll back to top.
3. `browser_wait_for` time: 1-2s
4. `browser_evaluate` to extract:
   - All `<img>` tags (src, alt, naturalW, naturalH, displayed dimensions, parent context)
   - All CSS `background-image` URLs (unique only)
5. Save per-page output to `/tmp/audit-<slug>.json`

### Phase 3 — Merge + categorize

- Combine per-page JSON outputs
- Dedupe by URL
- Cross-reference against any existing `manifest.json` — only new URLs proceed to download
- Categorize using heuristics on URL + alt + parent context:
  - `logo` in URL OR parent is `<nav>`/`<header>` → `logo/`
  - Page is `/events/[slug]` → `events/` (case study photos)
  - Page is `/about` AND parent is team section AND portrait-ish dimensions → `team/`
  - Page is `/about` AND parent is press/article section → `press/`
  - `Textured` or `background` in URL → `misc/`
  - Default (large image) → `hero/`

### Phase 4 — Download

- Parallel `curl` with `&` for speed (not sequential — loses 10× on a 50-file scrape)
- Filenames: strip Webflow hash prefix (`66610296..._`), URL-decode, lowercase, kebab-case
- Collision handling: append `-2`, `-3`, etc.
- Update `manifest.json` with each new asset

### Phase 5 — Self-verification (the important bit)

After downloads:
1. Walk each per-page JSON
2. For each image URL, check whether a local file exists that maps to it via the manifest
3. Compute **coverage %** per page (downloaded / total unique)
4. Retry failed downloads once
5. Skip tiny tracking pixels (< 50×50 px) and known placeholder SVGs
6. Write `audit/asset-coverage-report.md` with:
   - Pages audited (count + list)
   - Total unique images found
   - Before/after download counts
   - Coverage % per page
   - Failed downloads with reasons
   - Anomalies (broken images on live site, etc.)

---

## Output structure

```
public/images/<client>/
├── logo/
├── hero/
├── events/          # or blog/, products/, whatever matches the site's content types
├── team/
├── press/
├── misc/            # textures, icons, misc
└── manifest.json    # old URL → local path, alt, category, dimensions

audit/
└── asset-coverage-report.md    # coverage % per page + failures
```

---

## Known gotchas

- **Lazy-loading.** Webflow, Squarespace, and most modern site builders lazy-load below-the-fold images. You MUST scroll the page before extracting or you'll miss most of the content.
- **`naturalW: 0, naturalH: 0`.** These aren't necessarily broken — often they're lazy-load placeholders that the page hasn't loaded yet. Capture the URL anyway and filter later if it's clearly a decorative SVG placeholder.
- **Webflow hash prefixes.** URLs come in as `hash_OriginalFilename.jpg`. Strip the hash for clean local filenames.
- **Duplicate URLs across pages.** Same hero photo often appears on homepage + about + services. Dedupe early, by URL.
- **Live site compression.** Webflow serves CDN-compressed versions on public URLs. For source-quality originals, you need the Webflow Assets API (requires admin token). For most preview-quality work, compressed is fine.
- **Broken images on the live site.** If the client's site has dead image references (e.g., missing portfolio thumbnails on LRY), your scrape will surface those as 404s. Report them — that's a "polish fix" moment for the migration.
- **Decorative placeholders.** Webflow adds `placeholder-image.svg` and `logo-webflow.svg` on pages in design mode — filter these.

---

## The reusable agent prompt

See `/Users/robert/Desktop/uphill-growth-sites/playbooks/asset-audit-agent-prompt.md` for the full prompt template. Key parameters to swap per client:

- `SITE_URL` (the live site root)
- `OUTPUT_DIR` (where `public/images/[client]/` lives)
- `PAGE_LIST` (top-level + collection strategy)
- `EXISTING_MANIFEST` (if re-running after a partial first pass)

---

## Future enhancements

- **Convert to a Claude Code slash command** (e.g., `/audit-assets https://oldsite.com ./public/images/newclient/`)
- **Image optimization layer** — after download, run `sharp` to generate WebP + AVIF variants at responsive widths (320w, 640w, 1200w) → ~60% smaller files
- **Webflow Assets API integration** — for source-quality originals (requires Webflow admin token, covers unused-but-uploaded assets)
- **Parallel multi-site mode** — for agencies running batched migrations
- **Video support** — currently images only; extend to capture `<video>` + `<source>` URLs
- **Delta mode** — given an existing manifest, only fetch new/changed assets (useful for keeping a mirror in sync)

---

## Success criteria for a run

- Every page on the client's live site visited
- ≥95% coverage per page (some gaps are unavoidable due to broken live assets)
- Zero failed-download retries outstanding at end
- `manifest.json` updated and consistent
- Coverage report written

If you hit 100% coverage, great. If you hit 95-99%, spot-check the gaps — they're usually broken images on the source site, which becomes feedback for the client meeting ("we noticed your portfolio has dead thumbnails").

---

## Target-Side Verification — catching what the source scrape doesn't

**The hole this closes:** downloading every asset from the source site is necessary but not sufficient. The rebuild can still ship with unfilled component slots (e.g., a 6-card category grid with gradient placeholders that look polished enough to be forgotten). Source-side coverage says "we got the photos"; target-side verification says "we wired them into the new site."

### The "IMAGE NEEDED" placeholder pattern

Every component that renders an image from data MUST have a fallback placeholder that:

1. **Uses a visually unmistakable pattern** — dashed magenta border, `IMAGE NEEDED` label, subject context (row title, category name, etc.). No gradients, no polished-looking stand-ins. Looks obviously unfinished.
2. **Contains the literal string `IMAGE NEEDED`** in the source code so it's grep-able
3. **Renders that same string to HTML** so it's visible in both the dev server preview AND any production output

Example (Astro):
```astro
{imageSrc ? (
  <img src={imageSrc} alt={imageAlt} class="..." />
) : (
  <div class="w-full h-40 border-2 border-dashed border-brand-magenta/40 ...">
    <p class="text-[10px] uppercase tracking-[0.18em] font-bold text-brand-magenta">Image needed</p>
    <p class="text-sm text-text-subtle">{title}</p>
  </div>
)}
```

### The verification checks (runs in seconds)

```bash
# 1. Source-level check — any unfilled placeholder slots in components?
grep -rn "IMAGE NEEDED" src/

# 2. Rendered-output check — any placeholder strings in live preview?
curl -s http://localhost:4321/ | grep -c "IMAGE NEEDED"
# (walk every route for full coverage)

# 3. Optional: fail the build if placeholders remain (for production)
# In package.json "prebuild" script:
#   ! grep -rq "IMAGE NEEDED" src/
```

**Zero hits on both checks = every slot filled.** Any hits = exactly what's still missing, with file:line references.

### Why this matters

On the LRY pilot, the 6 client-category cards originally had colorful gradient placeholders. They looked intentional. It took Robert pointing them out for them to get replaced. With the dashed-border `IMAGE NEEDED` pattern + grep check, that class of miss can't survive to production.

### Pre-launch checklist addition

Add to every migration's ship checklist:

- [ ] `grep -rn "IMAGE NEEDED" src/` returns zero results
- [ ] `curl -s http://localhost:4321/<every-route> | grep "IMAGE NEEDED"` returns zero
- [ ] Asset coverage report shows ≥95% per page
- [ ] All `<img src>` URLs resolve (no 404s in dev console)

### Design principle (durable)

**When something is missing, make it loud.** Silent placeholders (gradients, blank boxes) turn into silent gaps in production. Dashed-border `IMAGE NEEDED` labels turn into audible alarms at every review cycle — both to the human reviewer AND to the grep-based self-check.
