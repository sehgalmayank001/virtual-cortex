---
name: brag-finder
description: Scan the last 30 days of journal entries for work wins the user forgot to log as #brag entries. Surfaces candidates as suggestions — the user confirms which to add. Performance-review prep. Use when the user says "find brags I missed", "/brag-finder", "what did I do this month", "scan for wins", or it's near review season.
---

# Brag Finder

Most engineers forget 80% of their wins by review time. This skill scans your journal for win-like activity that you didn't tag as `#brag` and suggests entries. You approve, the bot adds.

## How to invoke

- `/brag-finder` — scan last 30 days
- `/brag-finder last-90-days` — quarterly review prep
- `/brag-finder 2026-04-01 2026-06-30` — Q2 explicit range
- Natural: "what did I do this quarter", "find brags I missed", "scan for wins"

## Steps

### 1. Compute the date range

Default: last 30 days from today. Convert each to Logseq journal page name.

### 2. Read each journal page

Use `mcp__mcp-logseq__get_page_content` per date. Skip dates with no journal.

### 3. Pattern match for win-like language

Scan every block for these signal phrases (case-insensitive):

**High signal** (very likely a brag):
- "shipped" / "we shipped" / "team shipped"
- "deployed" / "we deployed" / "rolled out"
- "fixed [bug|issue|...]" / "we fixed" / "squashed"
- "launched" / "we launched"
- "delivered" / "we delivered"
- "merged" (especially with PR numbers)
- "led" / "spearheaded" / "drove" / "chaired"
- "mentored" / "onboarded" / "coached"
- "reduced [latency|cost|time]" / "cut [latency|cost|time] by"
- "saved [hours|days|$]" / "freed up"
- "architected" / "designed the" / "built the"

**Medium signal** (might be a brag, check context):
- "decided to" / "chose" (could be a decision worth bragging)
- "presented" / "demoed" / "walked through"
- "wrote [doc|RFC|design]" / "authored"
- "reviewed" / "audited"
- "debugged" / "triaged" / "root-caused"
- "unblocked" / "cleared the way for"
- "closed [ticket|issue|project]" / "wrapped up"

**Skip these** (not brags):
- "tried to X but failed"
- "started working on X" (incomplete)
- "asked X about Y" (just communication)
- Items marked CANCELED
- TODOs assigned to other people

### 4. Filter out things already tagged as brag

Skip any block that already contains `[[brag]]` or `tags:: brag`. Those are already logged.

### 5. Surface candidates to the user

Present the list in chat, NOT as a write to Logseq yet:

```
Found N candidate brags in the last 30 days:

1. <date> — "<win phrasing pulled from journal>"
2. <date> — "<win phrasing>"
3. <date> — "<win phrasing>"
...

Reply with the numbers you want to log as brags, or "all" / "skip".
```

The candidates are the user's own journal phrasing, surfaced verbatim — don't rewrite them.

### 6. After user confirms, write brag blocks

For each confirmed candidate, append a block to today's journal (NOT to the original day).

**Formatting:** write the brag with same-block properties matching the `brag` template — a `tags::` line plus `what-i-did::`, `impact::`, `evidence::`, all un-dashed directly under the title so they attach to the parent block.

Block format:

```markdown
- {one-line title}
  tags:: brag
  what-i-did:: {original block content, verbatim from the user's journal}
  impact:: 
  evidence:: [[{original journal date}]]
```

Notes:
- `tags:: brag` surfaces the block on the brag hub (add the work hub too if the win is work-specific, e.g. `tags:: brag, <work-hub>`)
- `evidence::` links back to the original journal day for context — the user can add PR links or metrics later
- `impact::` is left blank — numerical impact is the user's to fill in
- `what-i-did::` is the verbatim phrasing the user originally wrote — don't rewrite it

### 7. Note voice for titles — notes, not docs

The one-line title is the only thing you phrase yourself (everything else is verbatim). Keep it note voice: terse, personal, reader is future-you.

- No markdown emphasis, no hand-holding phrases
- Over 12 words? Try cutting half
- Swaps: "implemented" → "added"/"did", "leveraged"/"utilized" → "used", "in order to" → "to"
- Plain language over code jargon — drop class/method names unless the title is meaningless without them; keep numeric thresholds (those sell the brag)

(Full version: logseq-note skill, "Notes are notes, not docs".)

## Worked example

```
User: /brag-finder

Bot: Scanning <range> (30 days)... found N candidates:

1. <date> — "<win 1>"
2. <date> — "<win 2>"
3. <date> — "<win 3>"
4. <date> — "<win 4>"
5. <date> — "<win 5>"

Which to log? (numbers, "all", or "skip")

User: all except 3

Bot: Logging 4 brags to today's journal.

[Writes 4 blocks under Jul 17, 2026]

Done. 4 brags logged. Open [[brag]] hub to see them all.
```

## Hard constraints

- **Suggest first, write second.** Never silently add brags. Always show candidates and wait for confirmation.
- **One block per brag in today's journal.** Don't backdate to the original day — that fragments the user's brag log.
- **Link back to the original date** via `evidence::` so context isn't lost.
- **Leave `impact::` blank.** Numerical impact is the user's to know.
- **Don't bullshit.** If you don't find anything, say so. Don't invent wins.

## Voice

No tool-call narration. No decorative tables or emoji. No long raw error-log dumps unless user asks. Standard tech acronyms OK (DB/API/MCP); never invent new abbreviations.

Abbreviate prose words (auth/config/req/res/fn/impl) — prose words only, never real code symbols or function names. Strip conjunctions; use arrows for causality (X → Y). One word when one word enough. Code symbols, function names, API names, error strings: never abbreviate.

No filler. No hedging. No "you", "your", "we". Keep sentences intact. Professional but tight.

**Example**

❌ "Excellent question! I'd be happy to help you find brags you might have missed. Let me scan your journal entries for the last 30 days and pattern-match for win-like language."

✅ "Scanning journal Jun 1–30. Found 4 candidates. Which should I log?"

## Don't

- Don't write brags to the original journal page (their day already happened)
- Don't auto-confirm — always wait for user numbers
- Don't include items already tagged `[[brag]]`
- Don't surface trivial items (one-word entries, half-finished drafts)
- Don't include action items the user owns but hasn't completed (those are TODOs, not brags)
- Don't editorialize ("This is a great win!"). Just surface the user's own words.

## Edge cases

- **Empty range**: say "No journal entries found Jun 16 – Jul 16. Nothing to scan." Don't fabricate.
- **All candidates already tagged**: say "Already on top of your brag game. No new candidates." (Compliment the user, brief.)
- **Ambiguous block** (could be brag or could be a TODO): include in candidates with a note `[uncertain]`. Let user decide.
- **User says "all"**: log everything. No confirmation per item.
- **User says "skip"**: write nothing. Confirm with "Got it, no brags added."

## Why this works

You wrote the wins in your journal already. They're there. You just didn't tag them. This skill is a forgetting-mitigation tool — it surfaces what was already true.

Best used:
- Once a month for ongoing brag log
- Right before performance reviews (90-day scan)
- After a big quarter when you can't remember everything you shipped
