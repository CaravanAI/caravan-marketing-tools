# Scout + Analysts Agent Pattern

The two-phase agent architecture that made the LRY audit scalable. Reusable for any research-then-synthesize task where phase 1 is serial and phase 2 splits into parallel deliverables.

---

## The pattern

```
Main agent
│
├─ Phase 1 — SCOUT (1 agent, serial)
│  ├─ Does heavy data collection (Playwright browsing, file reading, API crawl, etc.)
│  ├─ Saves raw output to disk (JSON, markdown, screenshots)
│  └─ Returns a brief summary + pointer to saved files
│
├─ Phase 2 — ANALYSTS (3-5 agents, parallel)
│  ├─ Analyst A: reads raw data → deliverable A
│  ├─ Analyst B: reads raw data → deliverable B
│  ├─ Analyst C: reads raw data → deliverable C
│  └─ Analyst N: reads raw data → deliverable N
│
└─ Main agent synthesizes deliverables → final output
```

**Why it works:** the scout's heavy output stays in the scout's context, not yours. Analysts run in parallel on the saved files, cutting wall-clock time by ~N. The main thread only ever sees compact summaries.

---

## When to use it

- **Research → synthesis tasks** with a natural serial/parallel split
- **Browser automation** tasks that must run in one browser (Playwright single-session)
- **Voluminous raw data** that would bloat main-thread context
- **Multiple independent deliverables** from the same underlying data

Classic examples:
- Site audits (scraping → brand doc + component inventory + rebuild plan + meeting brief)
- Competitive research (visit competitors → positioning doc + pricing comparison + feature matrix)
- API schema extraction (crawl endpoints → types file + client library + docs + test scenarios)
- Security reviews (scan codebase → vulnerability list + severity triage + remediation plan)

---

## When NOT to use it

- **Simple one-step tasks.** Don't overengineer.
- **When deliverables depend on each other.** Parallel analysts can't see each other's output. If B needs A's output as input, sequence them (or merge into a synthesis step).
- **When the scout task is already fast.** If collection takes 30 seconds, just do it on the main thread.
- **When analysts would produce wildly overlapping work.** Either collapse them into one, or add clear non-overlap scope per analyst.

---

## The scout prompt template

```
You are the SCOUT AGENT. Your job is data collection, not analysis.

## Context
[1-2 sentences on the overall mission]

## Tool loading (if MCP tools are deferred)
Load via ToolSearch: select:<tool1>,<tool2>,<tool3>

## Output directory
All output goes to: <absolute path>
- Raw dumps → <subdirectory>
- Summary → <main output file>

## Per-item procedure
For each <page/endpoint/file>:
1. [specific step]
2. [specific step]
3. Save output to <disk path>

## Final deliverable
A structured markdown report at <path> containing:
- What was captured (list)
- Tech/tool observations
- Page-by-page notes
- Data file index
- Anomalies / issues

## Rules
- Use `filename` param on tools to write to disk when possible (keeps response small)
- Skip trivial items (tiny images, empty pages)
- Don't close browsers / terminate processes — main thread may need them
- Report back a BRIEF summary (~150 words) + pointer to saved files
```

---

## The analyst prompt template

```
You are ANALYST <A/B/C/D>. Your job: produce <one specific deliverable> from the scout's saved output.

## Inputs (read these first)
- <path to scout's summary>
- <path to relevant raw data>
- <path to any reference material>

## Reference (for style consistency)
- <path to existing work this should mirror>

## Your output
Write to <exact file path>

<Structured list of sections to include, with specifics for each>

## Principles
- [1-3 guiding principles specific to this deliverable]

Keep it practical. No marketing language. ~1-2 pages.
```

---

## Spawning them correctly

### Phase 1 (scout)

```js
Agent({
  description: "...",
  subagent_type: "general-purpose",
  run_in_background: true,   // optional — if main can do other work
  prompt: <scout prompt>,
})
```

### Phase 2 (analysts, parallel)

**Single message, multiple Agent calls.** This is critical — the whole point is parallelism.

```js
// In ONE message:
Agent({ description: "Analyst A...", run_in_background: true, prompt: <A prompt> }),
Agent({ description: "Analyst B...", run_in_background: true, prompt: <B prompt> }),
Agent({ description: "Analyst C...", run_in_background: true, prompt: <C prompt> }),
Agent({ description: "Analyst D...", run_in_background: true, prompt: <D prompt> }),
```

---

## Synthesis step (main thread)

After analysts complete:

1. Read each deliverable file
2. Produce the final output — usually a navigation-hub doc (CLAUDE.md, README, project brief) that:
   - Summarizes each deliverable in a few bullets
   - Links to the full file
   - Distills key decisions into a single place
3. Save synthesis as the authoritative doc

The individual deliverables remain as detailed backup; the synthesis is what new sessions read first.

---

## Trade-offs

- **Wall-clock time:** scout + parallel analysts is usually 2-4× faster than one serial agent doing everything
- **Context efficiency:** main thread stays clean, better for long-running sessions
- **Cost:** N+1 agents vs 1 agent — more tokens, but usually worth it for quality + speed
- **Complexity:** more moving parts, more opportunities for cross-agent confusion. Mitigated with clear per-agent scope.
- **Parallel blind-spots:** analysts can't see each other's work. Acceptable if scopes are non-overlapping.

---

## Real-world case: LRY site audit (2026-04-16)

**Scout (1 agent, serial, ~14 min):**
- Drove Playwright through 8 LRY pages + 2 case studies
- Saved 18 screenshots + 14 data files (snapshots, tokens, motion, network)
- Wrote `audit/scout-findings.md` (raw report)

**Analysts (4 agents, parallel, ~2-5 min each):**
- Analyst A: `01-brand-system.md` (colors, typography recommendation, buttons, spacing)
- Analyst B: `02-component-inventory.md` (19 patterns → Preline mapping, custom flags)
- Analyst C: `03-rebuild-plan.md` (Astro architecture, forms, tracking, timeline)
- Analyst D: `04-meeting-brief.md` (1-page peer-to-peer talking doc)

**Main thread synthesis:** `lry-cc/CLAUDE.md` — navigation hub linking to all four deliverables + decisions distilled.

**Total wall-clock:** ~20 min for an audit that would take a single agent 45+ min.

---

## Common mistakes

1. **Giving the scout analysis responsibilities.** Keep scout pure data collection. Analysis is the analysts' job.
2. **Spawning analysts sequentially instead of parallel.** Must be in a single message with multiple Agent calls.
3. **Not writing outputs to disk.** Agents are ephemeral — their context dies when they finish. Always save to files the main thread can read.
4. **Analysts that share a file path.** Each analyst gets its own output path to prevent overwrites.
5. **Main thread trying to see the scout's full output.** If the scout's summary isn't enough, something's wrong — the scout should write a better summary, not dump everything back.
