# Own Your Site — Operating Principles

The spine the skills reason from. When a situation isn't spelled out in a skill's
step-by-step, fall back to these. The goal: the tool handles reality on its own, so a
non-technical owner never needs someone standing over their shoulder.

1. **Never dead-end.** If something's missing — no intake profile, no sitemap, no
   connected browser — pick a safe default and keep going. Never bounce the user out or
   stop with "run X first." State the assumption you made, and move on.

2. **Safe-by-default for someone's business.** This is a real company's website. Default
   the new code repo to **private**. Preserve existing URLs (and the Google rankings tied
   to them). Wire forms to a working endpoint. Never break what they already have.

3. **Capture what the browser renders, not the raw tag.** Read images and brand from what
   actually paints — `currentSrc`, `srcset`, `<picture>`, lazy-load `data-src` — after
   scrolling to trigger lazy content. The naive `src` attribute under-counts on modern
   CMS sites and shows up later as "IMAGE NEEDED" gaps.

4. **Verify each distinct thing once.** Fidelity-check one representative page *per
   template* (home + one of each distinct layout) — not just the homepage, not every page.

5. **Resumable, not restart.** Long browser walks checkpoint per page. If the connection
   drops or the run is re-invoked, resume from the first page that isn't done yet — never
   start the whole walk over.

6. **Promise only what you actually do.** Don't give time or day estimates for the build —
   this isn't a multi-day agency engagement. Speak to *complexity* instead (how much is
   straightforward vs genuinely custom) and let the work speak for itself.

7. **Degrade silently, never gate visibly.** When a premium helper (artifact board,
   Advisor, best-model browsing) isn't available on the user's plan, quietly take the
   universal path. The user should never hit a "you can't do this" wall.

8. **Authoritative sources win.** A provided brand guideline outranks anything scraped off
   the live site. The client's own content and decisions outrank our guesses.
