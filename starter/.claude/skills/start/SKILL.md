---
name: start
description: Welcome + intake interview for Own Your Site. Invoke when the user says "hi", "hello", "let's start", "help me get started", asks "what does this do" / "how do I use this", expresses confusion or uncertainty, or mentions wanting to migrate a website. Runs a short 6-question intake (URL, platform, dynamic features, copy-vs-redesign, comfort with GitHub/Vercel) and writes a profile to `.own-your-site/notes.md` that downstream skills read. Safe — no destructive actions, no migration triggered.
argument-hint: "[source-url]"
allowed-tools: Bash Write Read AskUserQuestion WebFetch
---

# Welcome to Own Your Site — Intake

5 minutes. Six questions. The output is a profile written to `.own-your-site/notes.md` that every other skill reads.

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

> Welcome. I have six quick questions to figure out the best path for you. Should take five minutes.

## Q1 — URL (open-ended)

> "What's the URL of the website you want to migrate?"

If `$ARGUMENTS` already contains a URL, skip this — confirm it and move on.

If the user says they don't have a website yet, gently redirect them: *"This tool migrates an existing website. If you're starting from scratch, you'll have a better experience using a different approach — Caravan can help, but Own Your Site isn't the right fit. Do you have any site at all, even a Squarespace draft?"* If they confirm they truly have nothing, end the intake here.

## Q2 + Q3 + Q4 — single AskUserQuestion call

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
    }
  ]
}
```

Then auto-detect the platform to verify the user's answer:

```bash
curl -s <url> | grep -oiE "(webflow|squarespace|wixstatic|wp-content|wp-includes|<meta name=\"generator\" content=\"[^\"]+\")" | head -5
```

If detection contradicts the user, surface it gently: *"Heads-up — the site looks like Webflow under the hood. OK if I treat it as Webflow?"*

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

## What the user wants
- Approach: copy | redesign | undecided
- Key frustration: <chosen>
- Comfort with GitHub/Vercel: yes | partial | none | skip

## Notes
(Claude can append progress notes here as the migration runs.)
```

## Recap and route

Recap in 2-3 sentences. Then route:

- Approach = "copy" or "undecided" → recommend `/migrate-site <url>`
- Approach = "redesign" → recommend `/migrate-site <url>` and tell Claude inside that flow to skip the fidelity check (we're rebuilding the design too, so divergences are intentional)

End with: *"When you're ready, run `/migrate-site` and we'll start. Your answers are saved in `.own-your-site/notes.md` — open it in any text editor anytime."*

## Principles

- **Six questions, no more.** Anything else can wait until it actually matters.
- **Capture frustrations and approach.** These guide downstream tone and routing more than anything else.
- **Don't paraphrase open-ended answers.** Quote what the user said verbatim in `notes.md`.
- **Be warm.** Many users will be slightly nervous. Reassure often.
