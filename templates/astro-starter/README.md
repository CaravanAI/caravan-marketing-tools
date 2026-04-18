# Astro Starter Template (placeholder)

This directory will contain the actual Astro + Tailwind + Preline starter template that `scaffold-astro` copies into new projects.

**Status:** placeholder for v0.1.0. A full starter will be extracted from a real pilot migration and shipped in `v0.2.0`.

**Expected contents** (once extracted):

```
astro-starter/
├── package.json              # Astro 6 + Tailwind v4 + Preline 4
├── astro.config.mjs
├── tsconfig.json
├── .gitignore
├── src/
│   ├── layouts/BaseLayout.astro
│   ├── components/
│   │   ├── Navbar.astro
│   │   ├── Footer.astro
│   │   ├── Button.astro          # with lift+shadow hover baked in
│   │   └── PlaceholderImage.astro # with IMAGE NEEDED pattern
│   ├── styles/global.css         # @theme with brand-swappable tokens
│   ├── scripts/preline.ts
│   └── pages/index.astro
└── public/
    └── favicon.svg
```

Until v0.2.0 ships, the `scaffold-astro` skill falls back to creating a bare-bones Astro project via `npm create astro@latest` and then patches in brand tokens + Preline setup from instructions in the audit.
