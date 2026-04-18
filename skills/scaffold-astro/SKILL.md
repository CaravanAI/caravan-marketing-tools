---
name: scaffold-astro
description: Scaffold a new Astro + Tailwind + Preline project from brand tokens. Creates the folder structure, base components (Navbar, Footer, placeholders), brand-theme CSS, and configs. Use after an audit has produced brand tokens, or standalone to start a fresh project from a brand spec file.
disable-model-invocation: true
argument-hint: "<output-dir> [brand-tokens-file]"
allowed-tools: Bash, Read, Write, Edit, Glob
---

# Scaffold Astro Project

Create a new Astro + Tailwind v4 + Preline UI project at $ARGUMENTS[0]. If $ARGUMENTS[1] is provided, use it as the brand tokens source; otherwise prompt the user for brand colors + fonts inline.

## Step 1 — Create scaffold

For v0.1.0, fall back to `npm create astro@latest` and patch in the conventions manually. Once `templates/astro-starter/` is filled in (v0.2.0+), copy it from `${CLAUDE_PLUGIN_ROOT}/templates/astro-starter/` to the output directory.

```bash
cd <output-dir>
npm create astro@latest . -- --template minimal --yes --no-install
npm install -D @astrojs/sitemap @tailwindcss/forms @tailwindcss/typography @tailwindcss/vite tailwindcss preline
```

## Step 2 — Wire in brand tokens

Read the brand tokens file (either the argument or `audit/01-brand-system.md` by default). Extract:
- Colors (navy, accent, canvas, surfaces)
- Fonts (heading, body, button)
- Button specs (border-radius, padding, font-weight)
- Spacing system

Write `src/styles/global.css` with:
- `@import "tailwindcss"`
- `@theme` block containing all tokens as CSS custom properties
- Button utility classes with lift + shadow hover pattern from `docs/component-polish.md`
- `IMAGE NEEDED` placeholder pattern styling

## Step 3 — Create base components

Create:
- `src/layouts/BaseLayout.astro` — HTML shell, font preconnects, `<slot>`
- `src/components/Navbar.astro` — logo left, links, CTA button right
- `src/components/Footer.astro` — logo, links, socials, copyright
- `src/components/PlaceholderImage.astro` — **dashed border + "IMAGE NEEDED" label** pattern
- `src/components/Button.astro` — primary + secondary variants with hover states
- `src/scripts/preline.ts` — Preline init
- `src/pages/index.astro` — skeleton homepage using Navbar + Footer + PlaceholderImage

## Step 4 — Config files

Write:
- `astro.config.mjs` — sitemap integration, `@tailwindcss/vite` plugin
- `tsconfig.json` — extends `astro/tsconfigs/strict`
- `package.json` — scripts (`dev`, `build`, `preview`) + pre-launch grep check

Add a `verify` script to `package.json`:

```json
"verify": "! grep -rq 'IMAGE NEEDED' src/ && echo 'No placeholders remaining' || (echo 'Found IMAGE NEEDED in src/' && grep -rn 'IMAGE NEEDED' src/ && exit 1)"
```

## Step 5 — Install + verify

Run `npm install`. Run `npm run dev` in the background. Return the localhost URL.

## Final output

Report:
- Output directory path
- Localhost URL (e.g., `http://localhost:4321`)
- File tree created
- Next steps (fill in Navbar links, Footer socials, homepage sections)

## Rules

- Always include `PlaceholderImage.astro` with the grep-able `IMAGE NEEDED` string
- Always wire `npm run verify` as a pre-launch gate
- Brand tokens go in `@theme` block (not tailwind.config.js — Tailwind v4 uses `@theme`)
- Button styles include rest + hover (with lift + shadow) + active states
