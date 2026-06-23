# Own Your Site

**Your website. Your voice. Your pace.**

Migrate any Webflow, Squarespace, Wix, or WordPress site to a self-owned Astro project — for free, in plain English, in about an hour. No subscription, no agency hourly rate, no learning curve. After it's yours, you change it by just *talking* to Claude.

Built and maintained by [Caravan](https://www.thecaravan.ai).

---

## Who this is for

You have a website you're paying a platform to host, and you'd like to **own** it instead — the actual code, on your computer, on hosting you control. You are **not** a developer, and you don't need to be. Your job is to say what you want; Claude does the building.

---

## Install

Own Your Site is a Claude Code plugin. You'll need [Claude Code](https://claude.com/claude-code) installed first:

- **Mac:** [How to install Claude Code on Mac](https://www.youtube.com/watch?v=R63hFl8hqcc)
- **Windows:** [How to install Claude Code on Windows](https://www.youtube.com/watch?v=NYrBuYDcnCE)

Then, inside Claude Code, add Caravan's marketplace and install the plugin:

```
/plugin marketplace add CaravanAI/caravan-marketing-tools
/plugin install own-your-site@caravan-marketing-tools
```

That's it. The rest is conversation.

> **Not sure if this is for you yet?** Copy [this prompt](paste-into-chatgpt-or-claude.md) into ChatGPT, Claude, or any AI chat. It'll walk you through what's about to happen and answer your questions before you commit.

---

## Quickstart

You don't need to memorize commands. After installing, just open Claude Code and say something like:

> "Help me migrate my website."

or paste your site's URL. Claude takes it from there with a short interview, then the migration.

If you prefer typing commands:

- `/own-your-site:start` — the intake interview (6 quick questions)
- `/own-your-site:migrate-site <your-url>` — the full rebuild
- `/own-your-site:launch` — put the finished site online

---

## What it does

You point it at your website. It:

1. Reads the sitemap so no page gets missed
2. Walks every page and captures your colors, fonts, and layouts
3. Downloads every image
4. Builds a clean Astro project on your computer
5. Compares the new site to the old one and flags any differences
6. Hands you a preview at `http://localhost:4321`

About 20 to 60 minutes depending on size. **Your live site stays untouched the whole time** — the new one is built into its own `new-site/` folder. When you're ready, `/own-your-site:launch` walks you through publishing to GitHub + Vercel + your domain.

---

## Prerequisites — how Claude looks at your site

The migration needs a browser to walk your site and capture each page. Pick whichever is easier for you:

**Easy path — Claude in Chrome (recommended):**
- [Google Chrome](https://www.google.com/chrome/) or [Microsoft Edge](https://www.microsoft.com/edge)
- The [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) (free)
- A direct Anthropic plan (Pro / Max / Team / Enterprise)
- Start Claude Code with `claude --chrome` (or run `/chrome` in a session)

This drives the browser you already use — nothing extra to install. (On the Pro plan, browser steps run on Haiku 4.5, which is fine for reading colors and fonts.)

**Advanced path — Playwright (headless, best for large sites):**
- [Playwright MCP](https://github.com/microsoft/playwright-mcp) installed in Claude Code
- Node.js / npm

The plugin uses Claude in Chrome when it's connected, and falls back to Playwright automatically.

---

## Recommended permissions

Claude Code asks permission before running commands. A plugin can't pre-approve these for you, so to avoid a wall of prompts during migration, you can paste this into your Claude Code settings (`~/.claude/settings.json`):

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

## How it works (for the curious)

The plugin lives at `plugins/own-your-site/`:

- **3 skills** — `start` (intake interview), `migrate-site` (the flagship), `launch` (deploy)
- **3 subagents** — `site-scout` (walks the source site and saves what it sees), `audit-analyst` (brand + components + rebuild plan), `visual-qa` (fidelity diff)
- **A first-run welcome hook** — greets newcomers once after install, then stays quiet

The architecture is a "scout + parallel analysts" pattern: one agent walks the source site in a single browser session, then analyst agents read the saved data to produce deliverables. Skills self-gate via a plain-English `notes.md` profile written during intake (kept in your project folder, alongside your site).

---

## Built by Caravan

Caravan is a Birmingham-based AI training and capacity-building company. We teach people to do real work with Claude — including building and running their own websites. This is one of the tools we use in class.

Want to learn how this is actually built? Take a Caravan class: [thecaravan.ai](https://www.thecaravan.ai).

---

## Contributing

Found a gap in coverage? A site pattern this doesn't handle well? Open an issue or PR. Most of the learnings in this tool came from real client migrations — yours can too.

When you change the plugin, bump the `version` in **both** `plugins/own-your-site/.claude-plugin/plugin.json` and the matching entry in `.claude-plugin/marketplace.json` (keep them equal) — otherwise installed users keep a cached older copy.

---

## License

MIT. Use it, fork it, build your own agency on top of it. Just keep the license file.
