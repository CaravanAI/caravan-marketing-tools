---
name: start
description: Welcome + intake interview for Own Your Site. Invoke when the user says "hi", "hello", "let's start", "help me get started", asks "what does this do" / "how do I use this", expresses confusion or uncertainty, or mentions wanting to migrate a website. Runs a short intake (URL, platform, dynamic features, copy-vs-redesign, GitHub/Vercel comfort, and Claude plan) and writes a profile to `.own-your-site/notes.md` that downstream skills read. Safe — no destructive actions, no migration triggered.
argument-hint: "[source-url]"
allowed-tools: Bash Write Read AskUserQuestion WebFetch
---

# Welcome to Own Your Site — Intake

About 5 minutes, a few quick questions. The output is a profile written to `.own-your-site/notes.md` that every other skill reads.

## Banner first

```
╔══════════════════════════════════════════════════╗
║                                                  ║
║   OWN YOUR SITE                                  ║
║   Your website. Your voice. Your pace.           ║
║                                                  ║
║   A Caravan toolkit · MIT licensed                ║
║                                                  ║
╚══════════════════════════════════════════════════╝
```

Then a one-line greeting:

> Welcome. I have a few quick questions to find the best path for you — about five minutes.

## How to ask — always use the picker, never plain text

Ask **every** question through the **AskUserQuestion** tool — the pop-up where the user clicks an option (or picks **Other** to type their own answer). Do **not** type questions as plain chat text and wait for a written reply. The pop-up picker is what makes the intake feel like a quick guided quiz, and it's far less work for a nervous newcomer than writing answers out.

The **only** free-text input is the site URL (Q1) — that has to be typed. Everything after it (Q2–Q7) is written below as AskUserQuestion calls; keep them that way, and keep the batching shown (Q2–Q4 in one pop-up, Q5–Q6 in one).

## Q1 — URL (open-ended)

> "What's the URL of the website you want to migrate?"

If `$ARGUMENTS` already contains a URL, skip this — confirm it and move on.

If the user says they don't have a website yet, gently redirect them: *"This tool migrates an existing website. If you're starting from scratch, you'll have a better experience using a different approach — Caravan can help, but Own Your Site isn't the right fit. Do you have any site at all, even a Squarespace draft?"* If they confirm they truly have nothing, end the intake here.

## Q2–Q5 — the site + design context (single AskUserQuestion call)

```
{
  "questions": [
    {
      "header": "Platform",
      "question": "What is the site built on?",
      "options": [
        {"label": "Webflow"},
        {"label": "Squarespace"},
        {"label": "Wix"},
        {"label": "WordPress"},
        {"label": "Something custom / hand-coded"},
        {"label": "I don't know"}
      ],
      "multiSelect": false
    },
    {
      "header": "Dynamic features",
      "question": "Does the site have any of these? (pick all that apply)",
      "options": [
        {"label": "Contact / lead-capture forms"},
        {"label": "Online store / e-commerce"},
        {"label": "Member login / accounts"},
        {"label": "Booking or scheduling"},
        {"label": "None — it's just informational"},
        {"label": "I'm not sure"}
      ],
      "multiSelect": true
    },
    {
      "header": "Approach",
      "question": "Do you want to closely match your current site, or use this as a chance to redesign?",
      "options": [
        {"label": "Match closely"},
        {"label": "Redesign — same content, fresh look"},
        {"label": "Not sure — I want to see what's possible"}
      ],
      "multiSelect": false
    },
    {
      "header": "Brand guide",
      "question": "Do you have brand guidelines — a logo, exact colors, and fonts in a document?",
      "options": [
        {"label": "Yes — I'll share a file/PDF"},
        {"label": "Yes — there's a link"},
        {"label": "No — just match my current site"},
        {"label": "Not sure"}
      ],
      "multiSelect": false
    }
  ]
}
```

Then auto-detect the platform to verify the user's answer:

```bash
curl -s <url> | grep -oiE "(webflow|squarespace|wixstatic|wp-content|wp-includes|<meta name=\"generator\" content=\"[^\"]+\")" | head -5
```

If detection contradicts the user, surface it gently: *"Heads-up — the site looks like Webflow under the hood. OK if I treat it as Webflow?"*

### If they have a brand guideline — get it and download it

If they picked "Yes — file" or "Yes — link", ask for it (free-text — like the URL, a path/link can't be a picker): *"Great — paste the link, or drop the file in this folder and tell me the filename."* This is the one other free-text input besides the site URL. Save the path/URL to the profile. The audit will **read it and treat it as the authoritative brand source** — it beats whatever we scrape off the live site. If they have no guideline, that's fine; we reverse-engineer the brand from the site.

## Q5 + Q6 — single AskUserQuestion call

```
{
  "questions": [
    {
      "header": "GitHub / Vercel",
      "question": "Do you have GitHub and Vercel accounts already? (We'll use them later to host the new site.)",
      "options": [
        {"label": "Yes, both"},
        {"label": "One but not the other"},
        {"label": "Neither — what are they?"},
        {"label": "I'd rather skip the deploy step"}
      ],
      "multiSelect": false
    },
    {
      "header": "Frustration",
      "question": "What's been most frustrating about your current setup?",
      "options": [
        {"label": "Cost — I'm tired of paying"},
        {"label": "Slow updates — I can't change things myself"},
        {"label": "Agency communication / bottleneck"},
        {"label": "Limited / broken features"},
        {"label": "Just want to own it"}
      ],
      "multiSelect": false
    }
  ]
}
```

## Q7 — Claude plan (final question)

One last question. Frame it as **capability, not status** — never make the user feel they have a lesser version. **The entire migration works on every plan;** this only tells you which optional helpers are available.

```
{
  "questions": [
    {
      "header": "Claude plan",
      "question": "Last one — which Claude plan are you on? Everything works on all of them; this just tells me which extra helpers I can turn on for you.",
      "options": [
        {"label": "Claude Pro"},
        {"label": "Claude Max"},
        {"label": "Team or Enterprise"},
        {"label": "Not sure"}
      ],
      "multiSelect": false
    }
  ]
}
```

What the answer enables (apply **silently** — never announce a limitation, never upsell):
- **Team / Enterprise** — the Advisor second-opinion on the rebuild plan and any design-artifact extras are available; if browsing via Claude in Chrome, it can use the best model.
- **Max** — Advisor available; design artifacts are not (those need Team/Enterprise).
- **Pro** — take the universal path; if browsing via Claude in Chrome it runs on Haiku 4.5 (fine for reading colors and fonts). No premium extras.
- **Not sure** — assume the safe baseline: universal path, nothing premium-gated.

If a helper turns out to be unavailable at runtime, **degrade silently** to the universal path — the user should never hit a "you can't do this" wall.

## Write the profile

Create `.own-your-site/notes.md` (mkdir -p the folder first if needed). Write a human-readable markdown file the user can open and edit themselves:

```markdown
# Own Your Site — Project Notes

**Started:** <ISO date>
**Phase:** intake-complete

## The site
- URL: <url>
- Platform (user said): <platform>
- Platform (detected): <platform>
- Dynamic features: <comma list>
- Brand guideline: <path / url / none>

## What the user wants
- Approach: copy | redesign | undecided
- Key frustration: <chosen>
- Comfort with GitHub/Vercel: yes | partial | none | skip

## Their setup
- Claude plan: Pro | Max | Team/Enterprise | unsure
- Premium helpers available: Advisor (Max / Team / Enterprise) · design artifacts (Team / Enterprise only)

## Notes
(Claude can append progress notes here as the migration runs.)
```

## Recap and route

Recap in 2-3 sentences. Then route:

- Approach = "copy" or "undecided" → recommend `/own-your-site:migrate-site <url>`
- Approach = "redesign" → recommend `/own-your-site:migrate-site <url>` and tell Claude inside that flow to skip the fidelity check (we're rebuilding the design too, so divergences are intentional)

End with: *"When you're ready, run `/own-your-site:migrate-site` and we'll start. Your answers are saved in `.own-your-site/notes.md` — open it in any text editor anytime."*

## Principles

- **Keep it light, no more than needed.** Anything else can wait until it actually matters. The intake should feel like a quick **tap-to-answer quiz** (AskUserQuestion pickers), not a wall of typed questions.
- **The plan question is capability, not status.** Everything works on every plan; never imply the user has a lesser version, never upsell, and degrade premium helpers silently when they're unavailable.
- **Capture frustrations and approach.** These guide downstream tone and routing more than anything else.
- **Don't paraphrase open-ended answers.** Quote what the user said verbatim in `notes.md`.
- **Be warm.** Many users will be slightly nervous. Reassure often.
