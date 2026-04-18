---
name: check-fidelity
description: Compare a rebuilt site (running at a localhost URL) against its source (live URL) section-by-section. Produces a divergence report with severity tags and recommended fixes. Use to verify parity before shipping a migration.
disable-model-invocation: true
argument-hint: "<source-url> <rebuild-url> [output-dir]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent
---

# Check Fidelity

Compare the rebuild at $ARGUMENTS[1] against the source at $ARGUMENTS[0]. Report goes to $ARGUMENTS[2] (defaults to `./audit/fidelity-report.md`).

## Spawn the visual-qa agent

Spawn the `visual-qa` subagent. Pass both URLs. It will:

1. Resize browser to 1440×900 (desktop pass)
2. Navigate to each URL, scroll through it, screenshot section-by-section
3. Extract computed CSS on primary container, heading, image, button of each section
4. Diff numerical values (> 5% = flag), categorical fields (font family, color, background-image presence), and booleans (edge-to-edge, has-texture)
5. Repeat at 390×844 (mobile pass)
6. Tag each divergence with severity: critical (visible to user) / moderate (spacing off) / minor (1-2px)
7. Write report with screenshot pairs + divergence list + recommended fixes

## Pre-flight source-side check (before visual-qa runs)

Run the grep-based linters on the rebuild first:

```bash
# Source-side: any unfilled component slots?
grep -rn "IMAGE NEEDED" <rebuild-path>/src/
# Rendered-side: any placeholder strings in rendered HTML?
curl -s <rebuild-url> | grep -c "IMAGE NEEDED"
```

If either returns non-zero, flag it to the user before running the expensive visual-qa pass. They can fix the placeholder gaps first and save runtime.

## Final output

Report back with:
- Critical / moderate / minor divergence counts
- Ship verdict (clean / revisions needed)
- Top 5 recommended fixes in priority order
- Path to full report

## Rules

- Intentional improvements (e.g., loading real web fonts when source has none) are NOT divergences. Note them as intentional in the report.
- Mobile and desktop are separate passes; both should be clean before shipping.
