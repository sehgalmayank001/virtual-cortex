---
name: logseq-note
description: Save a piece of conversation, decision, learning, or idea to the user's Logseq graph. Scans content for multi-tag signals (decision, brag, incident, etc.) and suggests all applicable tags — not just the obvious one. Defaults to today's journal entry unless content needs its own page. Use when the user says "save this to logseq", "logseq this", "remember this", "/logseq-note", "add to my notes", or similar.
---

# Save to Logseq

Capture one takeaway from the conversation into Logseq. Terse. Tagged. In the user's voice.

Invoke on: `/logseq-note`, "save this to logseq", "logseq this", "remember this", "note this down". All the same.

## The one rule that matters: notes are notes, not docs

You are writing for future-you, who already has the context. Not for a newcomer.

**Length budget (hard):**
- Title line + **at most 3 bullets**. Most notes are title + 1 bullet.
- Each bullet is **one line, ≤ 12 words**. Over 12? Cut half.
- If it can't fit, it's probably two notes — or the user wants a page (ask).

**Cut on sight:**
- Hand-holding: "for the user", "this is by design and the UI confirms it" — state the rule once.
- Restatement: don't explain the same thing two ways.
- Markdown emphasis (`**bold**`, `*italic*`), section headings for a single point.
- Class names, table/column names, method jargon — unless the point literally hinges on that exact name. Keep numeric thresholds; those are signal.

**Word swaps:** implemented→did/added, leveraged/utilized→used, architected→built, "applies to"→needs, "in order to"→to.

Bad (docs voice):
> The feature only applies to users meeting condition X and condition Y. Users not meeting both will not see it — this is by design, and the UI states "...".

Good (notes voice):
> feature needs X AND Y. else no go.

Match the user's tone. Informal in, informal out.

## Steps

### 1. Find the takeaway

One line: what's worth keeping? Usually the thing just discussed — a decision, a trick/learning, a todo list, a discussion summary, or an idea worth keeping. If unclear, ask — don't dump the whole conversation. Skip trivia ("user asked about X").

### 2. Scan for ALL tags — REQUIRED

Content is often 2-4 tags at once. Scan every category — never pick the obvious one and stop.

**brag** — trigger phrases: "shipped", "deployed", "merged", "delivered", "launched"; "fixed", "debugged", "diagnosed", "ruled out", "identified" (a pattern/root cause/bug); "led", "mentored", "onboarded"; "reduced", "saved", "improved" (with a metric); "decided", "closed the loop on", "resolved". Also: **the user proving something *isn't* a bug** (correct diagnosis = brag). Any performance-review-worthy work.

**decisions** — needs an actual CHOICE: option X over Y, or a deliberate will/won't-do.
- "We chose X over Y because..."
- "After investigating, we'll proceed with..."
- A trade-off comparison with a chosen path
- "We'll leave it / won't fix / change the process" — a forward-looking call counts.

**A diagnosis is NOT a decision.** "Not a bug", "by design", "root cause is X" with no choice made = `brag` (correct diagnosis) + the topic hub, NOT `decisions`. Don't add `decisions` because something was explained or ruled out — only if someone decided to do or not do something as a result. Unsure → leave off, ask.

**incidents** — production downtime, outage, customer impact; "p1/p2/sev1/sev2"; a timeline of events leading to a failure.

**[[people/<name>]]** — names in attendee/discussion context; feedback or decisions credited to a person.

**work hub + topic** — ticket IDs (PROJ-1234, JIRA codes) → that company's hub; codebase/internal-product names → matching work hub; specific work people → that work context. Add `<work-hub>/<topic>` for the topic page.

**Never pick one tag and stop. Most notes have 2-4 tags.** A debugging analysis that proves a reported bug wasn't real is `brag` AND work-hub AND topic — but NOT `decisions` unless a choice was made off the back of it.

Other entity hubs to tag against when they fit: `meetings`, `companies`, `books`. Topic/tech/life hubs too (`python`, `react`, `AI`, `AWS`, `learning`, `career`...). Run `list_pages` if you need the user's real hubs. Don't invent hubs mid-flow.

### 3. Tag format — `tags::` same-block property under the title

Put tags on a `tags::` line directly under the title bullet, **un-dashed** (the shape `/template` produces). The tags attach to the parent title block, so the note surfaces on every hub you list.

✅ Correct — `tags::` un-dashed, right under the title:
```
- <title>
  tags:: brag, <work-hub>, <work-hub>/<topic>
  - <one short bullet>
```

❌ Wrong — dashed, so it becomes a separate child block and the title stays untagged:
```
- <title>
  - tags:: brag, <work-hub>
```

Self-check: `tags::` is un-dashed, immediately under the title; scalar props (`type::`, `status::`) written bare, not bracketed; hub names with `/` (like `<work-hub>/<topic>`) go in the comma list as-is. If the note doesn't show on its hub after writing, re-index once (Logseq → Re-index) — API/file writes lag the live index.

### 4. Propose in one line, then write

State the plan with the full tag set and why any non-obvious tag is there. One line, not three questions:
> "Journal block today, `tags:: brag, <work-hub>`. brag = diagnosed both tickets as non-bugs. Title: '<A> + <B> not bugs — <topic>'. ok?"

On confirm, write it. Default target: today's journal (`mcp__mcp-logseq__update_page`, append). Confirm where it landed in one line — no "Saved successfully!".

Why the scan matters — same content, two outcomes:
> ❌ passive dump: `- The reported issues are not bugs because...` → no tags, lost in the journal forever.
> ✅ scanned: detect brag (correct diagnosis) + work-hub + topic, NO `decisions` (no choice made). Tag `brag, <work-hub>, <work-hub>/<topic>`, title names the tickets. Surfaces on every hub.

### 5. Journal block vs own page

Journal block is the default. Own page only if: 3+ real sections, referenced from many places, a reusable doc (runbook/plan/architecture), or the user says so. When in doubt, journal — easier to promote later.

Journal block format:
```markdown
- {one-line title}
  tags:: tag1, tag2, tag3
  - {key point in plain language}
```

Own page format — tags as a page property on the first block, then content:
```markdown
tags:: {comma-separated tags}

## Context
{why this exists}
## What
{the content}
## Why / decision (if any)
{reasoning}
```

## Rule-surfacing — rare, and still short

Debugging/analysis notes mix two things: **case data** (ephemeral — ticket IDs, user IDs, timestamps) and **durable knowledge** (timeless — how the system works, rules, constants). When durable knowledge is present, surface the rule instead of burying it under case data, and tag the topic hub so it's findable later.

A reusable rule is present when you see: "by design / always / only when / must be", "X works like Y" / "X requires Y" / "if X then Y", a condition/threshold/constant, "to check this, look at..." (a debugging method), or several cases all explained by the same underlying rule. Absent all of these it's just case work — skip this section.

When detected: lead with the rule (title or first bullet), cases after, one line each, tagged with the topic hub. Do NOT manufacture `## Rule` / `## Debugging` / `## Cases` headings — one `rule:` bullet does it. Keep the length budget.

```markdown
- <A> + <B> not bugs — <topic>
  tags:: brag, <work-hub>, <work-hub>/<topic>
  - rule: <the condition, plain words, one line>
  - <A>: <one-line case>. <B>: <one-line case>.
```

**When NOT to apply** — skip the rule bullet, just write the takeaway:
- Pure case work, no general lesson ("user Y reported Z, fixed by Q")
- A decision already context-specific ("we chose X for Q3 capacity")
- Routine debugging ("found a typo, fixed it")

## Code snippets

Strip by default. Paraphrase: "fix was `==` → `===`" beats pasting the function. Keep a snippet only if the point is unintelligible without it.

## Journal page name format

`<MonAbbr> <D><ordinal>, <YYYY>` — e.g. `Jun 13th, 2026`, `Jan 1st, 2026`, `Mar 23rd, 2025`.

Months: Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec. Ordinals: 1st/2nd/3rd, 4th–20th "th", 21st/22nd/23rd, 24th–30th "th", 31st "st".

## Tools

- `mcp__mcp-logseq__update_page` (append) — journal blocks, appending to a page
- `mcp__mcp-logseq__create_page` — new dedicated page
- `mcp__mcp-logseq__get_page_content` — check a page exists first
- `mcp__mcp-logseq__list_pages` — discover hubs

## Hard constraints

- Stay within the length budget — verbose = wrong, even if accurate.
- Always run the multi-tag scan (step 2). Skipping it = the passive-dump failure.
- Default to a journal block; own pages are the exception.
- Suggest the full tag set in one line — don't ask three questions.
- Only the takeaway, never the whole conversation. Use existing hubs, don't invent tags.
- Say where it landed in one line — no "Saved successfully!".

## Voice

No tool-call narration. No decorative tables or emoji. No long raw error-log dumps unless user asks. Standard tech acronyms OK (DB/API/MCP); never invent new abbreviations.

Abbreviate prose words (auth/config/req/res/fn/impl) — prose words only, never real code symbols or function names. Strip conjunctions; use arrows for causality (X → Y). One word when one word enough. Code symbols, function names, API names, error strings: never abbreviate.

No filler. No hedging. No "you", "your", "we". Keep sentences intact. Professional but tight.

**Example**

❌ "Sure! Let me help you save that to your Logseq graph. I noticed your conversation contains a decision and a brag. Let me scan for the right tags..."

✅ "Saving as journal block, tagged decisions, brag, <work-hub>. Title: 'Chose Celery over SQS for Q3 capacity'. Sound good?"

## Don't

- Dash the `tags::` line (makes it a child block, untags the title).
- Pick one tag when there are several signals.
- Ask the user to re-explain what they just said.
- Dump code blocks, the whole conversation, or AI voice ("Here's what we did:").
- Invent a hub/powertag mid-flow (propose it after, separately), or add source attribution ("from Claude Code session").

## When unsure

Ask one focused question with 2-3 concrete options — never open-ended "where should I put this?":
- "Tag `decisions, <work-hub>` or `brag, <work-hub>`?"
- "Journal block or its own page?"
- "Keep the snippet or paraphrase?"
