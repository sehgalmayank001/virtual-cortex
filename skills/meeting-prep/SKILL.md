---
name: meeting-prep
description: Prepare for an upcoming meeting by surfacing the last 3 meetings with the same person/group, plus any open action items they owe and any the user owes them. Writes a prep block under today's journal. Use when the user says "prep for meeting with X", "/meeting-prep X", "what do I have on <person>", or pastes a person name asking about meeting history.
---

# Meeting Prep

Pulls a focused prep block for an upcoming meeting. Surfaces the last 3 meetings + open action items in both directions. Goes in today's journal as a single block.

## How to invoke

- `/meeting-prep Bob` — prep for next meeting with `people/Bob`
- `/meeting-prep juan-miguel` — match the namespaced name
- Natural: "prep for my 1:1 with <person> tomorrow", "what's the history with <person>", "I have a meeting with <person> — what do I need to remember"

## Steps

### 1. Resolve the person

The argument is a person name (or a partial). Resolve to a `people/<name>` page:

1. Try exact match: `people/Bob`
2. If not found, fuzzy match against existing `people/*` pages — show 2-3 options if ambiguous
3. If still no match, ask the user to clarify

Use `mcp__mcp-logseq__list_pages` to get the existing namespace; filter to entries starting with `people/`.

### 2. Get backlinks

Use `mcp__mcp-logseq__get_page_backlinks` on the resolved person page. Returns every block that references `[[people/<name>]]` — usually meeting blocks with `attendees:: [[people/<name>]]`.

### 3. Filter to meeting blocks

Each backlink is a block. Keep only blocks that are meeting captures (typically: link to `[[meetings]]`, contain `attendees::`, `time::`, etc.). Sort by date descending (most recent first).

### 4. Pull open action items

Within those meeting blocks, find any `TODO` items. Classify:

- **They owe me**: TODO items where the user's name is NOT in parens (or no parens at all), AND the action is in a meeting they attended
- **I owe them**: TODO items where the user's first name IS in the parens (e.g. `(Alice)` if user is named Alice), in a meeting they attended

Skip items already marked `DONE` or `CANCELED`.

### 5. Write the prep block

Append to today's journal:

```markdown
- ## Prep — {person's name}
  - ### Last 3 meetings
    - {date} — {title}
      - {1-2 line gist from the summary}
    - {date} — {title}
      - {1-2 line gist}
    - {date} — {title}
      - {1-2 line gist}
  - ### They owe me ({count})
    - TODO {item} (from {meeting title}, {date})
  - ### I owe them ({count})
    - TODO {item} (from {meeting title}, {date})
  - ### Suggested agenda
    - 
    - 
```

Skip empty sections. Leave "Suggested agenda" blank — the user fills it in.

## Worked example

User: `/meeting-prep alice`

Output:

```markdown
- ## Prep — Alice
  - ### Last 3 meetings
    - Jun 17, 2026 — 1:1 with Alice
      - Discussed Q3 priorities, agreed to scope down a feature
    - Jun 10, 2026 — Team standup
      - Alice flagged a project as on-track
    - Jun 3, 2026 — Tech showcase demo
      - Alice showed a new feature, customer success liked it
  - ### They owe me (1)
    - TODO Send me the Q3 plan (from 1:1, Jun 17)
  - ### I owe them (2)
    - TODO Review Alice's PR (from standup, Jun 10)
    - TODO Decide on launch date by Friday (from 1:1, Jun 17)
  - ### Suggested agenda
    - 
    - 
```

## Hard constraints

- **One block in today's journal, not a separate page.**
- **Last 3 meetings only.** More is noise — this is *prep*, not history.
- **Distinguish ownership of TODOs.** Failing to do this is the main reason prep blocks become useless.
- **Quote the source meeting** for every action item (so user can click through to context).
- **No invented action items.** Only items literally present in past meeting blocks.

## Don't

- Don't include meetings older than 6 months unless the user asked for full history
- Don't write a long narrative summary — bullets only
- Don't auto-fill the "Suggested agenda" — that's the user's prep work
- Don't include `DONE`/`CANCELED` action items
- Don't tag the prep block — it's in the journal, that's enough

## Edge cases

- **Person not found**: ask user to clarify, suggest 2-3 closest matches
- **No past meetings**: say so. "No previous meetings found with `people/Bob`. Starting fresh — what's the agenda?"
- **Group meetings** (3+ attendees): prep block focuses on what *this person* contributed. Don't repeat unrelated discussion.
- **Multiple people with same firstname**: use the full namespaced name (`people/juan-miguel` vs `people/juan`)
- **Person attended but didn't speak / no notes about them**: skip their meeting in the "Last 3" list, find an earlier one
