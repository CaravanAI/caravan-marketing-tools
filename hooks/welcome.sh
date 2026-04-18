#!/bin/bash
# own-your-site — first-run welcome hook
#
# Fires on SessionStart. On first-run only, injects welcome context
# that Claude reads before responding to the user's first message.
#
# To test the welcome again after initial run:
#   rm ~/.claude/plugins/data/own-your-site-*/.first_run_seen

set -e

FIRST_RUN_MARKER="${CLAUDE_PLUGIN_DATA}/.first_run_seen"

if [ -f "$FIRST_RUN_MARKER" ]; then
  # Not the first run — stay silent.
  exit 0
fi

mkdir -p "${CLAUDE_PLUGIN_DATA}"
touch "$FIRST_RUN_MARKER"

# stdout on SessionStart is added to Claude's context as "additional context."
# See hooks.md § SessionStart decision control.

cat <<'EOF'
[own-your-site plugin — first-run notice]

The user has just installed the Own Your Site plugin for the first time in this Claude Code session.

If they do not immediately invoke a specific command or ask a specific question in their first message, proactively greet them:

1. Welcome them warmly in 1-2 sentences. Name the plugin and what it does in plain language.
2. Reassure them that their CURRENT website is never touched — this plugin builds a separate local copy they can look at and decide about.
3. Offer two paths:
   - "If you'd like a guided walkthrough, just say 'help me get started' or type /own-your-site:start"
   - "If you already know what you want, you can jump in with /own-your-site:migrate-site <your-url>"
4. Invite their first question.

Adapt to their fluency from their first reply:
- Uncertain, tentative, or non-technical tone → invoke /own-your-site:start for structured handholding
- Confident and specific ("I have a Webflow site, want Astro") → route directly to the relevant skill

Do NOT push or repeat the welcome. If they ignore the offer and ask about something else, respond to what they actually asked.

This notice fires only on the first session after installing the plugin. It will not appear again unless the plugin is reinstalled.

[end notice]
EOF

exit 0
