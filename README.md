# Own Your Site

**Your website. Your voice. Your pace.**

Migrate any Webflow, Squarespace, Wix, or WordPress site to a self-owned [Astro](https://astro.build) project — in plain English, by talking to Claude. No subscription, no agency retainer, no learning curve. Once it's yours, you change it just by asking.

![License: MIT](https://img.shields.io/badge/license-MIT-802a02)
![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-6a744d)
![Built by Caravan](https://img.shields.io/badge/built%20by-Caravan-c8c2a8)

Built and maintained by [Caravan](https://www.thecaravan.ai).

---

## Quickstart

You'll need [Claude Code](https://claude.com/claude-code) installed. Then, inside it:

```text
/plugin marketplace add CaravanAI/caravan-marketing-tools
/plugin install own-your-site@caravan-marketing-tools
```

Then just talk to it:

> "Help me migrate my website."

…or paste your site's URL. Prefer commands? `/own-your-site:start` → `/own-your-site:migrate-site <url>` → `/own-your-site:launch`.

> **New to Claude Code?** Install guides: [Mac](https://www.youtube.com/watch?v=R63hFl8hqcc) · [Windows](https://www.youtube.com/watch?v=NYrBuYDcnCE).
> **Not sure it's for you?** Paste [this primer](paste-into-chatgpt-or-claude.md) into any AI chat first — it'll walk you through what's about to happen.

---

## What it does

You point it at your website. It:

1. Reads the sitemap so no page gets missed
2. Walks every page and captures your colors, fonts, layouts, and images
3. Builds a clean Astro project on your computer
4. Compares the new site to the old one and flags any differences
5. Hands you a preview at `http://localhost:4321`

**Your live site is never touched** — the new one is built into its own `new-site/` folder. When you're ready, `/own-your-site:launch` walks you through publishing to GitHub + Vercel + your domain, and tells Google about the move so your search rankings carry over.

Have brand guidelines (logo, exact colors, fonts)? Hand them over during the intake and they become the source of truth for the rebuild — and for every edit you make afterward.

---

## Who it's for

You have a website you're paying a platform to host, and you'd rather **own** it — the actual code, on hosting you control. You are **not** a developer, and you don't need to be. Your job is to say what you want; Claude does the building.

---

## Prerequisites

The migration needs a browser to walk your site. Pick whichever is easier:

**Easy path — Claude in Chrome (recommended)**
- Google Chrome or Microsoft Edge + the free [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn)
- A direct Anthropic plan (Pro / Max / Team / Enterprise)
- Start Claude Code with `claude --chrome` (or run `/chrome`)

**Advanced path — Playwright (headless, best for large sites)**
- [Playwright MCP](https://github.com/microsoft/playwright-mcp) + Node.js / npm

The plugin uses Claude in Chrome when it's connected and falls back to Playwright automatically.

---

## How it works

The plugin lives at `plugins/own-your-site/`:

- **3 skills** — `start` (intake), `migrate-site` (the flagship rebuild), `launch` (deploy)
- **3 subagents** — `site-scout` (walks the source site), `audit-analyst` (brand + components + rebuild plan), `visual-qa` (fidelity check, one page per template)
- **A first-run welcome hook** — greets newcomers once after install, then stays quiet
- **[`PRINCIPLES.md`](plugins/own-your-site/PRINCIPLES.md)** — the operating principles the skills reason from, so the tool handles edge cases on its own (never dead-end, safe-by-default, capture what renders, …)

The architecture is a "scout + analysts" pattern: one agent walks the source site, then analyst agents read the saved data to produce deliverables. The intake writes a plain-English profile to `.own-your-site/notes.md` that the other skills read; if it's missing, the flagship proceeds on safe defaults rather than stopping.

---

## Recommended permissions

Claude Code asks before running commands. A plugin can't pre-approve these, so to skip a wall of prompts during migration, paste this into your Claude Code settings (`~/.claude/settings.json`):

```json
{
  "permissions": {
    "allow": [
      "Bash(curl *)", "Bash(grep *)", "Bash(sed *)", "Bash(awk *)",
      "Bash(mkdir *)", "Bash(ls *)", "Bash(find *)", "Bash(wc *)",
      "Bash(sort *)", "Bash(uniq *)", "Bash(npm *)", "Bash(npx *)", "Bash(node *)",
      "Read", "Write", "Edit", "Glob", "Grep", "WebFetch"
    ]
  }
}
```

Prefer to approve each step yourself? Skip this — Claude will just ask as it goes.

---

## Built by Caravan

[Caravan](https://www.thecaravan.ai) is a Birmingham-based AI training and capacity-building company. We teach people to do real work with Claude — including building and running their own websites. This is one of the tools we use in class.

Want to learn how it's built? Take a Caravan class.

---

## Contributing

Found a gap in coverage? A site pattern this doesn't handle well? Open an issue or PR — most of what this tool knows came from real client migrations.

When you change the plugin, bump the `version` in **both** `plugins/own-your-site/.claude-plugin/plugin.json` and the matching entry in `.claude-plugin/marketplace.json` (keep them equal) — the version is the cache key, so installed users won't get your changes otherwise.

---

## License

[MIT](LICENSE). Use it, fork it, build your own agency on top of it — just keep the license file.
