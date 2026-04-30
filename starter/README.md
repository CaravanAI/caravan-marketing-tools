# Start Here

You downloaded this folder because you have a website you don't fully own — it's on Webflow, Squarespace, Wix, or WordPress, and someone is charging you to keep it online — and you'd like that to stop.

In about an hour, you'll have a clean copy of your site running on your computer, in code you own, that you can change in plain English from now on. No subscription, no agency hourly rate, no learning curve.

## Three honest things before you start

1. **Caravan isn't getting paid for this.** It's free. No upsell.
2. **This is how we built our own website** at [thecaravan.ai](https://www.thecaravan.ai). We trusted these tools on our own site before asking you to trust them on yours.
3. **This is new and you might hit a snag.** If you do, tell us what went wrong — open an issue at [github.com/CaravanAI/own-your-site](https://github.com/CaravanAI/own-your-site).

## How to start

You need **Claude Code** installed on your computer. If you don't have it yet:
- **Mac:** [install guide video](https://www.youtube.com/watch?v=R63hFl8hqcc) (3 min)
- **Windows:** [install guide video](https://www.youtube.com/watch?v=NYrBuYDcnCE) (3 min)
- Or download from [claude.com/claude-code](https://claude.com/claude-code)

Once Claude Code is installed:

- **Mac:** double-click `migrate.command` in this folder.
- **Windows:** double-click `migrate.bat` in this folder.

That's it. Claude greets you and walks you through it.

If the double-click doesn't work, open a terminal in this folder manually and run `claude`. (Mac: right-click the folder in Finder → "New Terminal at Folder." Windows: open Git Bash, type `cd `, drag this folder onto the window, press enter.)

**You don't need to memorize any commands.** Just say what you want in plain English. *"Hi, I want to migrate my site."* — Claude figures out the rest.

## What's about to happen

Claude asks you six quick questions to understand your situation. Then:

1. Reads your site's sitemap (finds every page)
2. Walks the site, screenshots every page, captures your colors and fonts
3. Downloads every image
4. Builds a clean Astro project on your computer
5. Compares the new version to your old site and flags differences
6. Hands you a preview at `http://localhost:4321`

About 20 to 60 minutes depending on size. You can watch it work or step away. When it's done, the new site lives in this folder. The old one is untouched.

## What you'll need later (Claude will help)

- **Node.js** — for building the site. Claude installs this when needed.
- **Playwright** — for reading your site. Claude installs this when needed.
- **GitHub + Vercel** — for putting the new site online. Free accounts. Run `/launch` after the migration and Claude walks you through both.

You don't need to set any of these up in advance. Claude tells you when each one is needed.

## A note on permission prompts

The first time Claude does something, you'll be asked to approve it. Common actions in this folder are pre-approved (reading files, running scripts) so you won't be hammered. For anything else, approve as you go.

## What you don't need to know

HTML, CSS, JavaScript, Astro, Tailwind, or any other code. How to set up a development environment. What "deployment" or "hosting" actually means. Anything about what your current site uses under the hood.

If you can describe what you want in a sentence, you can run this.

## If something goes sideways

1. Tell Claude what looks off, specifically. ("The hero photo is missing.")
2. If you're stuck, type `/start` to walk through the guided flow again.
3. If you suspect a real bug, [open an issue on GitHub](https://github.com/CaravanAI/own-your-site/issues).

## After the migration

Once the new site exists, you can:

- **Run `/launch`** — wraps GitHub + Vercel + your domain into one continuous flow. Claude handles the technical pieces; you click "yes" a few times.
- **Edit it in plain English.** *"Change the hero headline to X. Add a testimonials section. Make the buttons rounder."* Claude does the typing.
- **Walk away.** The site is yours. It works. Touch it again whenever you want.

## Where this came from

[Caravan](https://www.thecaravan.ai) is a Birmingham-based AI training company. We teach people to do real work with Claude — including building and running their own websites. This is one of the tools we use in class.

The code is open source under MIT. Use it, fork it, build your own agency on top of it.

---

**Your website is yours. Welcome home.**
