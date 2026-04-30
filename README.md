# Own Your Site

**Your website. Your voice. Your pace.**

Migrate any Webflow, Squarespace, Wix, or WordPress site to a self-owned Astro project — for free, in plain English, in about an hour. No subscription, no agency hourly rate, no learning curve.

Built and maintained by [Caravan](https://www.thecaravan.ai).

---

## For non-technical users

If you have a website you'd like to own and want to use this tool, **download the `/starter` folder** and follow the README inside it. The starter is a self-contained kit you drop on your computer, open in Claude Code, and follow along.

[**→ Download the starter folder**](starter)

If you're not sure whether this is for you, copy [this prompt](paste-into-chatgpt-or-claude.md) and paste it into ChatGPT, Claude, or any other AI chat. The AI will walk you through what's about to happen and answer your questions before you commit.

You'll need [Claude Code](https://claude.com/claude-code) installed on your computer:
- **Mac:** [How to install Claude Code on Mac](https://www.youtube.com/watch?v=R63hFl8hqcc) (3 min video)
- **Windows:** [How to install Claude Code on Windows](https://www.youtube.com/watch?v=NYrBuYDcnCE) (3 min video)

That's it. The rest is conversation with Claude.

---

## What it does

You point it at your website. It:

1. Reads the sitemap so no page gets missed
2. Walks every page, captures your colors, fonts, and layouts
3. Downloads every image
4. Builds a clean Astro project on your computer
5. Compares the new site to the old one and flags differences
6. Hands you a preview at `http://localhost:4321`

About 20 to 60 minutes depending on size. Your live site stays untouched the whole time. When you're ready, run `/launch` and Claude walks you through publishing to GitHub + Vercel + your domain.

---

## What's in this repo

```
own-your-site/
├── starter/                          ← The downloadable product
│   ├── README.md                     ← Onboarding guide for users
│   ├── CLAUDE.md                     ← Claude Code bootloader
│   ├── migrate.command               ← Mac double-click launcher
│   ├── migrate.bat                   ← Windows double-click launcher
│   └── .claude/                      ← Skills, agents, settings
└── paste-into-chatgpt-or-claude.md   ← Pre-flight prompt for any AI chat
```

The `starter/` folder is what users download. Everything else here is repo metadata.

---

## How it works (for the curious)

The `starter/.claude/` folder holds the actual logic:

- **3 skills** — `/start` (intake interview), `/migrate-site` (the flagship), `/launch` (deploy)
- **3 subagents** — `site-scout` (Playwright walker), `audit-analyst` (brand + components + plan), `visual-qa` (fidelity diff)
- **1 settings file** — pre-approved permissions + a SessionStart hook (project-scoped, doesn't touch the user's machine)

The architecture follows a "scout + parallel analysts" pattern: one agent walks the source site serially in a single browser session, then analyst agents read the saved data in parallel to produce deliverables. Skills self-gate via a human-readable `notes.md` profile written by the intake.

---

## Built by Caravan

Caravan is a Birmingham-based AI training and capacity-building company. We teach people to do real work with Claude — including building and running their own websites. This is one of the tools we use in class.

If you'd like to learn how any of this is actually built, take a Caravan class: [thecaravan.ai](https://www.thecaravan.ai).

---

## Contributing

Found a gap in coverage? A site pattern this doesn't handle well? Open an issue or PR. Most of the learnings in this tool came from real client migrations — yours can too.

---

## License

MIT. Use it, fork it, build your own agency on top of it. Just keep the license file.
