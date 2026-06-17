---
name: logseq-note
description: Save a piece of conversation, decision, learning, or idea to the user's Logseq graph. Scans content for multi-tag signals (decision, brag, incident, etc.) and suggests all applicable tags — not just the obvious one. Defaults to today's journal entry unless content needs its own page. Use when the user says "save this to logseq", "logseq this", "remember this", "/logseq-note", "add to my notes", or similar.
---

# Save to Logseq

Captures something from the current conversation into Logseq. Picks the right spot, **detects every applicable tag (not just one)**, writes it cleanly, confirms.

## How to invoke

- Slash: `/logseq-note`
- Natural: "save this to logseq", "logseq this", "remember this", "add this to my notes", "note this down"

Both work. Treat them the same.

## What to save

The user usually means "the thing we just talked about" — could be:
- A decision we just made
- A trick or learning from this session
- A list of things to do
- A discussion summary
- An idea worth keeping

Ask the user what specifically if it's not obvious. Don't dump the whole conversation.

## Steps

### 1. Read the room

Skim the recent conversation. Figure out:
- What's the one-line summary?
- What topic does it belong to? (look at the user's hubs — typically python, react, AI, learning, plus work-specific hubs)
- Is it small enough for a journal block, or does it need its own page?

### 1a. Surface the rule, don't bury it — REQUIRED for debugging/analysis content

If the content is a debugging analysis, customer case, or "Not a bug" explanation, it usually contains TWO kinds of information mixed together:

- **Case data** (ephemeral) — specific ticket IDs, user IDs, timestamps
- **Durable knowledge** (timeless) — how the system actually works, rules, constants, debugging steps

**Both stay in the same journal block** — but the rule must be SURFACED, not buried below case data. And the block must be **tagged with the topic** so the rule is findable via the topic hub later.

**Signals that durable knowledge is present:**

- "by design", "always", "only when", "must be"
- "X works like Y" / "X requires Y" / "if X then Y"
- Conditions, percentages, thresholds, constants
- "To check this, look at..." (debugging methodology)
- Multiple cases analyzed against the same underlying rule

**When detected, do three things:**

1. **Reorder content** so the rule is the FIRST child heading, debugging steps are SECOND, case data is LAST
2. **Tag with the topic** as a hub link (e.g. `<work-hub>/token-bonus` or `<work-hub>/subscriptions`) — this is what makes the rule discoverable later
3. **Use distinct headings** (`## Rule`, `## Debugging`, `## Cases`) so a reader sees the rule first

**Example proposal:**

> "Detected a system rule here. Saving as a journal block with structured headings — Rule first, Debugging second, Cases last. Tagging with `brag, <work-hub>, <work-hub>/token-bonus` so it shows on the token-bonus topic page. (No `decisions` — nothing was decided, it's a diagnosis.) Sound good?"

**CRITICAL formatting — write tag references INLINE on the title line, not as a `tags::` property.**

Why: when this skill writes to Logseq via the mcp-logseq MCP server, that server's parser does NOT recognize `tags::` lines under a bullet as parent properties. It creates them as separate empty child blocks with the property attached to those phantom children. Result: the title block is untagged, the hub displays an empty bullet as the surfaced reference.

The workaround: put hub references **inline on the title line**, separated by `—`. Logseq treats inline `[[ref]]` exactly like `tags:: ref` for backlinks and queries.

✅ **CORRECT — references inline on the title:**

```
- <title> — [[decisions]] [[brag]] [[<work-hub>]] [[<work-hub>/<topic>]]
  - ## Rule
    - ...
```

The title block contains the references. Queries on any hub find this block. Hub displays the full title with references. No phantom blocks.

❌ **WRONG — tags:: as a property line under title:**

```
- <title>
  tags:: decisions, brag, <work-hub>, <work-hub>/<topic>
  - ## Rule
```

The mcp-logseq parser breaks it — see the MCP parser source (`_parse_list_item` in `parser.py` has no `LOGSEQ_PROPERTY_PATTERN` handling for nested content).

❌ **WRONG — `tags::` as a bulleted child:**

```
- <title>
  - tags:: decisions, brag
  - ## Rule
```

The dash makes `tags::` a separate child block. Same parent-untagged problem.

**Self-check before writing:**

1. Title line ends with `— [[hub-1]] [[hub-2]] [[hub-3]]...`
2. No `tags::` property line anywhere in the block
3. References use `[[double-bracket]]` syntax — works for hub names with `/` like `<work-hub>/<topic>`
4. Mentally render: does the title block ITSELF contain the references? If yes, correct. If they're on a separate line, fix.

**Worked example of the block structure** (everything stays in ONE block in today's journal):

```markdown
- <ticket-A> + <ticket-B> not bugs — <topic> — [[brag]] [[<work-hub>]] [[<work-hub>/<topic>]]
  - ## Rule
    - <condition that must hold> for <behavior> to happen, in plain words
    - <what the system keys off> — name the concept, not the class
  - ## Debugging
    - Check <key thing> first — if <value>, done
    - Otherwise check <related history> for <pattern>
    - <latest wins / first wins / etc.>
  - ## Cases
    - <ticket-A> — <one-line case summary>. Not a bug.
    - <ticket-B> — <one-line case summary>. User-initiated / system-caused / etc.
```

Fill the angle-bracket placeholders with the specific terms from the user's input. The pattern is what matters — the bullets are short, the rule comes first, the cases come last.

Now:
- Future-you opens `<work-hub>/token-bonus` → sees this entry via backlinks → reads the rule first
- The case context is still there (last section) if needed
- One journal entry, one place, but the rule isn't buried

**When NOT to apply this:**

- Pure case work with no general lesson ("user Y reported issue Z, fixed by Q")
- Decisions that are already context-specific ("we chose X for Q3 capacity")
- Routine debugging ("found a typo, fixed it")

If the analysis is just "this user did X" with no underlying rule, just use the standard structure (no `## Rule` heading needed).

### 1b. Scan for multi-tag signals — REQUIRED

A piece of content can be a decision AND a brag AND tagged with a project at the same time. Scan for ALL of these, not just the most obvious one.

**Brag-worthy signals → propose `brag` as one of the tags:**
- "shipped", "deployed", "merged", "delivered", "launched"
- "fixed", "debugged", "diagnosed", "ruled out", "identified" (a pattern, root cause, bug)
- "led", "mentored", "onboarded"
- "reduced", "saved", "improved" (with a metric)
- "decided", "closed the loop on", "resolved"
- **The user proving something *isn't* a bug** (correct diagnosis = brag)
- Any performance-review-worthy work

**Decision signals → propose `decisions`:**
- A decision needs an actual CHOICE: option X picked over option Y, or a deliberate "we will / won't do Z".
- "We chose X over Y because..."
- "After investigating, we'll proceed with..."
- A trade-off comparison with a chosen path
- "We'll leave it / won't fix / change the process" — a forward-looking call counts.

**A diagnosis is NOT a decision.** "Not a bug", "by design", "root cause is X" with no choice made = a `brag` (correct diagnosis) plus the topic hub. Do NOT add `decisions` just because something was explained or ruled out. Only add it if someone actually decided to do or not do something as a result. When unsure, leave `decisions` off and ask.

**Incident signals → propose `incidents`:**
- Production downtime, outages, customer impact
- "p1 / p2 / sev1 / sev2"
- Timeline of events leading to a failure

**People signals → propose `[[people/<name>]]`:**
- Names in attendee/discussion context
- Quoted feedback or decisions credited to a person

**Project signals → propose work hub tag:**
- Ticket IDs like PROJ-1234, JIRA codes → that company's hub
- Codebase names, internal product names → matching work hub
- Mentions of specific work people → that work context

**Never pick one tag and stop.** Most notes have 2-4 tags. A debugging analysis that proves a reported bug wasn't real is a `brag` AND a work-hub (and topic) entry — but NOT a `decision` unless a choice was made off the back of it.

### 2. Suggest a plan with the full tag set

Tell the user what you'll do in one line, with ALL detected tags. Explain *why* each non-obvious tag was suggested.

**Good example:**
> "Saving as a journal block today, tagged `decisions, brag, <work-hub>`. Brag is for diagnosing both tickets as non-bugs. Title: '<ticket-A> + <ticket-B> not bugs — <one-line topic>'. Sound good?"

**Bad example** (passive dump):
> "Saving this to logseq."

The bad version loses tags and context. The good version names tags and explains why — user can correct in one word.

Only ask multiple questions if categorization is truly unclear after step 1a.

### 3. Pick journal block vs own page

**Journal block** (default):
- Single decision, learning, or idea
- Fits in 1–10 lines
- You don't expect to link to it from other pages

**Own page**:
- Has 3+ distinct sections or headings
- The user will reference it from multiple places later
- It's a reusable doc (architecture overview, runbook, plan)
- Or the user explicitly said "make a page for this"

When in doubt, journal. Easier to promote later than to demote.

### 4. Reference the user's existing hubs

The user's graph has these hubs you can tag against:

**Entity hubs (for new instances):**
- `meetings`, `people`, `companies`, `brag`, `books`, `incidents`, `decisions`

**Topic hubs (use as `tags::`):**
- Work project namespaces (run `list_pages` to discover the user's actual hubs)
- `python`, `react`, `AI`, `system-design`, `AWS`, `GCP` — tech topics
- `learning`, `career`, `diet` — life areas

A note can have multiple tags. E.g. a Python-related decision at the user's job → `tags:: decisions, python, <work-hub>`.

### 5. Write the block

**Journal block format** (use inline references, not `tags::` — see "CRITICAL formatting" section above):

```markdown
- {one-line title} — [[tag1]] [[tag2]] [[tag3]]
  - {key points in plain language}
  - {one more point}
```

**Own page format:**

```yaml
---
tags: {comma-separated tags}
---
```
```markdown
## Context
{why this exists}

## What
{the content}

## Why / decision (if applicable)
{reasoning}
```

### 6. Code snippets

Strip them out by default — they're rarely the point. Keep only the explanation.

**Exception:** include the snippet if the explanation needs it (e.g. "this regex bug is on line X" — keep the line; "the fix was a one-character change" — keep it).

When in doubt, paraphrase: "the fix was changing `==` to `===`" beats pasting the whole function.

### 7. Worked example — multi-tag detection

User dumps a debugging analysis in conversation (two reported bugs, both turn out to be not bugs after investigation), then says "save this to logseq".

**Wrong response** (passive dump):

```markdown
- The reported issues are not bugs because...
```

No tags. Lost in the journal forever.

**Right response:**

Detect:
- User correctly diagnosed both reports as non-defects → **brag** signal
- Tickets mention a specific product area → **work hub** + topic signal
- No choice was made off the back of it → NO `decisions` tag

Suggest:
> "Saving as a journal block today, tagged `brag, <work-hub>, <work-hub>/<topic>`. Brag is for diagnosing both as non-bugs. Title: '<ticket-A> + <ticket-B> not bugs — <one-line topic>'. Sound good?"

On confirmation, write a block with:
- A clear one-line title naming the tickets and topic
- Inline `[[references]]` on the title line for all detected tags
- Bullets in plain language: what the system actually does + why each ticket isn't a defect
- A final "Action" bullet if next step is needed

This entry surfaces on the `brag` hub and the work/topic hubs. If the team later decides "won't fix / change X" off the back of it, THAT follow-up is the `decisions` note — separate from this diagnosis.

### 8. Notes are notes, not docs

This is the most common failure mode: writing detailed documentation when the user wanted terse notes.

**Notes** = punchy, personal voice, assumes the reader knows the context (because it's future-you).
**Docs** = thorough, reader-friendly, explains for newcomers.

**The skill writes NOTES.** Cut:

- Hand-holding phrases: "for the user", "must be... to qualify", "if X then Y" — just state the rule
- Redundant restatement: don't say something is "by design" AND quote the UI text confirming it — pick one
- Markdown emphasis: no `**bold**` or `*italic*` — notes don't need styling
- Long sentences: chop them. Period. Done.

**Word-level swaps:**
- "Implemented" → "did" / "set up" / "added"
- "Leveraged" / "Utilized" → "used"
- "Architected" → "designed" / "built"
- "applies to" → "needs"
- "in order to" → "to"
- "the new checkout's interval is what X writes" → "new interval wins (X writes it)"

**Compression test:** if a bullet has more than 12 words, try cutting half. Usually possible.

**Bad (docs voice):**
> The <feature> only applies to users meeting condition X and condition Y. Users not meeting both conditions will not see the feature — this is by design, and the UI even states "<exact quote from UI>".

**Good (notes voice):**
> <feature> needs X AND Y. Otherwise = no go.

Same info. Half the words. Reads like the user wrote it.

**Default to plain language. Add code references only when needed.** Notes describe behaviour in everyday words, not class names. Drop `ClassName#method`, table/column names, and method jargon unless the note is meaningless without them (e.g. the rule literally hinges on that exact field, or the user asks to keep them). Keep specific numeric thresholds — those are signal. When unsure, write it plain and leave the code out.

Match the user's tone. Informal in, informal out.

### 9. Confirm

After writing, tell the user where it went in one line:

> "Saved to [[<today>]] under `decisions, brag, <work-hub>`."

## Tools to use

- `mcp__mcp-logseq__update_page` (append mode) for journal blocks or appending to existing pages
- `mcp__mcp-logseq__create_page` for new dedicated pages
- `mcp__mcp-logseq__get_page_content` to check if a page exists first
- `mcp__mcp-logseq__list_pages` if you need to see all hubs

## Journal page name format

Logseq journal pages: `<MonAbbr> <D><ordinal>, <YYYY>` — e.g. `Jun 13th, 2026`, `Jan 1st, 2026`, `Mar 23rd, 2025`.

Months: Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec.

Ordinals: 1st, 2nd, 3rd; 4th–20th use "th"; 21st, 22nd, 23rd; 24th–30th use "th"; 31st use "st".

## Hard constraints

- **Default to journal block.** Own pages are the exception.
- **Always run step 1a (multi-tag scan).** Skipping it = the passive dump failure mode.
- **Suggest the full tag set in one line, don't ask three questions.**
- **Don't include the whole conversation.** Only the takeaway.
- **Don't make up tags.** Use ones already in the user's graph.
- **Don't add fluff** like "Saved successfully!" — say where it went.

## Don't

- Don't dump full code blocks unless the explanation needs them
- Don't write in AI voice ("Here's what we did:") — write in user voice
- Don't ask the user to re-explain what they just said
- Don't pick one tag when content has multiple signals — always scan all 5 signal categories in step 1a
- Don't create a new hub or powertag mid-flow — propose it after, separately
- Don't save trivial stuff ("user asked about X") — only durable takeaways
- Don't add source attribution like "from Claude Code session" / "from Cursor chat". Noise.

## When unsure

Ask one focused question with 2-3 concrete options. Examples:
- "Tag with `decisions, brag, <work-hub>` or just `decisions, <work-hub>`?"
- "Journal block or its own page?"
- "Include the code snippet or paraphrase?"

Never ask "where should I put this?" — too open.

