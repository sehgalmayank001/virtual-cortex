---
name: weekly-review
description: Generate a weekly review by scanning the last 7 days of Logseq journal entries. Extracts brags, decisions, completed TODOs, open TODOs, and incidents into a structured block under today's journal. Use when the user says "weekly review", "/weekly-review", "what did I do this week", "sunday review", or it's a Sunday/Friday and they ask for a recap.
---

# Weekly Review

Scans the user's journal for the past 7 days and produces a structured review. Lives under today's journal as a single block — don't create a separate weekly review page.

## How to invoke

- `/weekly-review` — last 7 days from today
- `/weekly-review last-2-weeks` — last 14 days
- `/weekly-review 2026-06-08 2026-06-14` — explicit date range
- Natural: "what did I do this week", "sunday review", "weekly recap"

If no range given, default to **last 7 days including today**.

## Steps

### 1. Compute the date range

Default: today minus 6 days through today (7 days inclusive).

Convert each date to Logseq journal page format: `<MonAbbr> <D><ordinal>, <YYYY>` (e.g. `Jun 12th, 2026`).

### 2. Read each journal page

Use `mcp__mcp-logseq__get_page_content` for each date in the range. Skip dates with no page (Logseq doesn't create journals for days you didn't write).

### 3. Extract from each day

Look for these patterns in the blocks:

- **Brags** — blocks containing `[[brag]]` link or `tags:: brag`
- **Decisions** — blocks containing `[[decisions]]` link or `tags:: decisions`
- **Meetings** — blocks containing `[[meetings]]` link or `tags:: meetings`
- **Completed TODOs** — blocks starting with `DONE ` marker
- **Open TODOs** — blocks starting with `TODO `, `LATER `, `NOW `, `DOING ` markers
- **Incidents** — blocks containing `[[incidents]]` link or `tags:: incidents`

### 4. Write the review block

Append to today's journal:

```markdown
- ## Weekly Review — {start date} to {end date}
  - ### Wins (brags)
    - {bullet per brag with date}
  - ### Decisions made
    - {bullet per decision with date}
  - ### Meetings ({count})
    - {one line each: title + date + attendees}
  - ### Completed this week ({count})
    - {bullet per DONE TODO}
  - ### Still open ({count})
    - TODO {bullet per open TODO from past 7 days}
  - ### Incidents
    - {bullet per incident}
```

Skip empty sections. If there were no brags, don't add an empty "### Wins" section.

### 5. Add a reflection prompt at the bottom

```markdown
  - ### Reflection
    - What went well: 
    - What didn't: 
    - Next week's focus: 
```

Leave these blank for the user to fill in. No markdown emphasis — notes don't need styling.

## Worked example

For a user reviewing Jun 12-18:

```markdown
- ## Weekly Review — <start date> to <end date>
  - ### Wins (N)
    - <one-line brag>, pulled verbatim from the journal (<date>)
    - <one-line brag> (<date>)
  - ### Decisions made (N)
    - <one-line decision> (<date>)
  - ### Meetings (N)
    - <meeting type> × N
    - <one-off meeting> (<date>) — attendees
  - ### Completed this week (N)
    - <done TODO> (<date>)
  - ### Still open (N)
    - TODO <open item> (from <date>)
  - ### Reflection
    - What went well: 
    - What didn't: 
    - Next week's focus: 
```

## Hard constraints

- **Write to today's journal, not a separate page.** Weekly reviews accumulate in journals — easy to find later.
- **No fabrication.** If the journal pages are empty, say so. Don't invent activity.
- **Preserve dates.** Every extracted item shows when it happened.
- **Don't summarize subjectively.** Surface the user's own words, not your interpretation.

## Don't

- Don't write a separate "Weekly Review YYYY-MM-DD" page
- Don't include items from before the date range, even if they're related
- Don't auto-fill the reflection section — that's the user's job
- Don't tag the weekly review block with anything (it's already in the journal — discoverable by date)
- Don't include trivial items (single-word notes, half-written drafts)

## Edge cases

- **Empty week**: tell the user "No journal entries found between X and Y. Skipping review." Don't write an empty block.
- **Only one or two days of entries**: still proceed, just note the gap.
- **Open TODO from older than 7 days**: skip it. This is a *weekly* review, not a TODO audit.
- **Action items assigned to others** (e.g. "(Bob)" when user is "Alice"): skip in "Still open" — only show the user's own.
