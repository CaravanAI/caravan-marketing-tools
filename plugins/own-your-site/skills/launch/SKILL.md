---
name: launch
description: Put the migrated site online. Wraps GitHub (code storage) + Vercel (hosting) + domain wiring into one continuous flow. Reads `.own-your-site/notes.md` to know whether the user has accounts already, and walks them through sign-up step-by-step if not. Use after `/own-your-site:migrate-site` finishes and the user is ready to go live.
argument-hint: ""
allowed-tools: Bash Read Write Edit WebFetch
---

# Launch — GitHub + Vercel + Domain

This is the deploy flow. The user has a working site at `http://localhost:4321`. This skill puts it online.

## Phase -1 — Read state

Read `.own-your-site/notes.md`. Phase must be `rebuild-complete`. If not, tell the user: *"The site needs to be built before we can launch it. Run `/own-your-site:migrate-site` first."*

Note the user's GitHub/Vercel comfort from the profile. Three branches:
- **"Yes, both"** — fast path, just push and deploy
- **"One but not the other"** OR **"Neither"** — walk through signup step by step
- **"I'd rather skip"** — confirm they want to skip, hand them the localhost preview, end here

## Phase 0 — Check the site builds

Before pushing anything online, make sure the site builds cleanly:

```bash
cd <project-dir>
npm run build
```

If errors, fix them first. Don't push broken code.

## Phase 1 — GitHub (code storage)

If the user has GitHub:

```bash
git init
git add .
git commit -m "Initial commit"
gh repo create <name> --private --source=. --push
```

**Private by default** (Principle 2) — a business's code shouldn't be world-readable. If they explicitly want it public, they can flip it in GitHub later.

If they don't have GitHub:

> "GitHub is a free service for storing code online. Like Google Drive, but for code. You'll sign up once, and then your website's code is backed up automatically.
>
> Open [github.com/signup](https://github.com/signup) — takes about 2 minutes. Pick any username. When you're done, come back and tell me."

After they sign up, install the gh CLI if needed (`brew install gh` on Mac, see [cli.github.com](https://cli.github.com) for Windows). Authenticate with `gh auth login`. Then run the commands above.

## Phase 2 — Vercel (hosting)

If the user has Vercel:

```bash
npx vercel --prod
```

Follow the CLI prompts. It will detect Astro and configure automatically.

If they don't have Vercel:

> "Vercel hosts your website. It's free for sites your size and very reliable. You'll connect it to GitHub once, and then every time you change your site Vercel automatically updates the live version.
>
> Open [vercel.com/signup](https://vercel.com/signup) — sign up with the same GitHub account. About 1 minute."

After signup, run `npx vercel --prod`. The first time it'll ask to link your GitHub repo — say yes.

## Phase 3 — Domain (only if the user has one to keep)

If the profile mentioned a domain to keep:

> "You said you want to keep using `<domain>`. We'll point that domain at the new Vercel-hosted site. Your old site can stay up until we're ready to switch over.
>
> In the Vercel dashboard, click your project, then 'Domains', then add `<domain>`. Vercel will show you the DNS records to add — usually one A record and one CNAME. Add those at your domain registrar (where you bought the domain — GoDaddy, Namecheap, etc.).
>
> DNS changes can take a few minutes to a few hours. We'll check in 15 minutes."

If the user doesn't have a domain, Vercel gives them a free `*.vercel.app` URL. That's fine for sharing the site.

## Phase 4 — Verify

Once Vercel reports the deployment is live:

1. Open the live URL in a browser
2. Click around — does everything render?
3. If there's a custom domain, wait for DNS to propagate, then test that too

If anything's broken in production but worked locally, it's almost always one of: env variables, image paths, or a build script issue. Walk through each.

## Phase 5 — Tell Google you moved (protect search rankings)

This is the step most DIY migrations skip — and it's how sites quietly lose their Google traffic. Frame it as protecting what they already earned, not a chore.

First, confirm any redirects deployed. If the audit's URL map flagged changed paths, they're in `vercel.json` and deploy automatically with the site. Spot-check one:

```bash
curl -sI https://<new-site>/<an-old-path> | grep -i location
```

It should point to the new path with a `301`.

Then walk the user through Google Search Console (free) in plain language:

> "Google already knows your old site. We just need to tell it about the new one so you keep your search rankings."

1. **Verify the site** at [search.google.com/search-console](https://search.google.com/search-console) — add the property for their domain. (If they kept the same domain and it was already verified, it carries over — nothing to do.)
2. **Submit the sitemap** — in Search Console → Sitemaps, submit `https://<domain>/sitemap.xml`.
3. **If the domain changed** (e.g. the old site was on a Webflow/Squarespace address and the new one is on their own domain): use Search Console's **Change of Address** tool on the old property to point it at the new one. Skip this if the domain is unchanged.
4. **Ask Google to re-check the homepage** — use the URL Inspection tool and click "Request indexing."

Reassure them: re-indexing takes a few days to a few weeks, a little ranking wobble is normal and recovers, and the redirects mean visitors lose nothing in the meantime. If they have a marketing person who owns Search Console, hand this list to that person instead.

## Phase 6 — Hand off

```
🎉 Your site is live at <url>.

What's next:
- Edit it in plain English. Just open Claude Code in this folder and tell it what you want.
- Every time you push changes to GitHub, Vercel updates the live site automatically.
- Google's been told about the move — your sitemap's submitted and your search rankings carry over.
- Your old site is still up. When you're ready to fully switch over, point your DNS at Vercel and turn off the old hosting.

Welcome home.
```

## Write back to notes

Update `.own-your-site/notes.md`:

```
**Phase:** deployed
**GitHub repo:** <url>
**Vercel project:** <url>
**Live URL:** <url>
**Custom domain:** <domain or null>
**Search Console:** sitemap submitted | change-of-address filed | unchanged-domain n/a
```

## Principles

- **No assumptions about technical literacy.** If they don't have GitHub, walk through signup. Don't say "just push to GitHub."
- **Reassure throughout.** This phase touches multiple services and can feel scary. Frequent reassurance: *"Your live site is still up. Nothing breaks until we switch the domain over."*
- **Stop early if requested.** If the user says they only wanted the localhost preview, that's a complete success. Don't push them toward deploy if they're done.
