---
name: meeting-sync
description: Sync meetings from any transcript tool (Granola, Otter, Fireflies, Fathom, tl;dv, etc.) into the Logseq journal entry for each meeting's date. Inserts a structured meeting block per meeting with inline [[meetings]] hub references on the title, scans the summary for durable rules and surfaces them in a Key insights section, auto-links attendees to people/<firstname> pages (creates stubs if missing). Defaults to most recent meeting; accepts a date or title arg. Use when the user says "sync meetings", "/meeting-sync", "import meeting", "save meeting to logseq", or similar.
---

# Meeting Sync

Pulls meetings from the user's transcript/summary tool and writes them to the corresponding day's Logseq journal as structured meeting blocks. Each block uses inline `[[meetings]]` references on the title (not `tags::` property — the mcp-logseq parser doesn't attach those to the parent bullet correctly). The tool's AI summary IS the meeting note — don't pull raw transcripts.

The skill also scans the summary for durable rules (system behavior decisions, debugging insights, agreements) and surfaces them in a `## Key insights` section at the top of the meeting block, with topic-page references on the title so the rule is findable on the topic hub later.

## Invocation modes

- `/meeting-sync` — most recent meeting
- `/meeting-sync today` — all meetings from today
- `/meeting-sync 2026-06-12` — all meetings on that date
- `/meeting-sync "Alice 1:1"` — search by title
- Natural language counts: "import yesterday's meetings", "sync standup", "save my meetings to logseq"

If nothing specified, default to **the most recent meeting**.

## Provider detection (with persistence)

The user's tool choice is stored on the `meetings` hub page as a `meeting-tool::` property (e.g. `meeting-tool:: granola`). This means detection only happens once.

### 0. Check for saved preference

Read the `meetings` hub page via `mcp__mcp-logseq__get_page_content("meetings")`. If it contains a `meeting-tool::` property, use that tool and skip to the Steps section.

Known values: `granola`, `otter`, `fireflies`, `fathom`, `tldv`, `manual`.

If no `meeting-tool::` property exists, proceed to step 1.

### 1. Check available MCP servers

Look for known meeting tool MCP servers already connected:

| Tool | MCP server pattern | List call | Get call | Summary field | Attendees field |
|------|--------------------|-----------|----------|---------------|-----------------|
| Granola | `*Granola*` or `*granola*` | `list_meetings` | `get_meetings` | `summary` | `known_participants` |
| Otter | `*otter*` | Discover via MCP tool listing | Discover | Varies | Varies |
| Fireflies | `*fireflies*` | Discover via MCP tool listing | Discover | Varies | Varies |
| Fathom | `*fathom*` | Discover via MCP tool listing | Discover | Varies | Varies |
| tl;dv | `*tldv*` | Discover via MCP tool listing | Discover | Varies | Varies |

If exactly one meeting tool MCP is found, use it. If multiple are found, ask the user which one to use. If none are found, go to step 2.

### 2. Ask the user

```
Which tool do you use for meeting transcripts/summaries?

1. Granola
2. Otter
3. Fireflies
4. Fathom
5. tl;dv
6. Other (tell me the name)
7. None — I'll paste summaries manually

If your tool has an MCP server, I'll need it connected first.
```

### 3. Save the choice

After the tool is determined (from step 1 or 2), add `meeting-tool:: <tool>` to the `meetings` hub page via `mcp__mcp-logseq__update_page`. Append it as a property line. Next time the skill runs, step 0 finds it and skips detection entirely.

If the user chose "None / manual", save `meeting-tool:: manual`.

### Manual paste — always available

Regardless of the saved tool, if the user pastes a meeting summary directly (or says "here are my meeting notes"), skip MCP calls and structure what they gave you. Don't ask "but you have Granola configured, want to use that instead?" — just process the paste.

This covers: meetings the tool didn't record, calls from a different app, notes from a phone call, or the MCP being temporarily down.

## Provider-specific notes

### Granola

- `list_meetings` accepts `time_range: "custom"` with `custom_start` + `custom_end`. Date format `YYYY-MM-DD`.
- `get_meetings` returns `summary` (markdown). The summary IS the note content.
- `summary` can be literal `"No summary"` when the tool hasn't processed the meeting yet. Insert the block anyway with the line "No summary available yet."
- No separate `action_items` field. Action items live in the summary markdown, usually under "### Next Steps" or "### Action Items". Convert those bullets to `TODO` blocks when writing.
- Don't call `get_meeting_transcript`. Raw transcripts add noise.
- `known_participants` entries are `Name <email>` or `Name from Org <email>`. The "(note creator)" entry is the user — skip it.
- Strip Granola's escape characters. Markdown like `\~30 minutes` should become `~30 minutes`. Backslash-escaped chars are formatting artifacts.

### Other tools (Otter, Fireflies, Fathom, tl;dv, etc.)

When an unfamiliar MCP server is detected:

1. List its available tools via the MCP tool listing
2. Identify the "list meetings" and "get meeting detail" equivalents
3. Call them and map the response fields to what this skill needs: **title**, **date/time**, **summary/notes**, **attendees/participants**
4. Proceed with the same block format below

The block format, attendee resolution, key insights extraction, and TODO discipline are identical regardless of which tool provides the data.

## Steps

### 1. List meetings

Use the provider's list call with appropriate date filtering.

### 2. Resolve attendees → people pages

Parse the attendees list from the provider. Skip:
- The meeting creator/host entry — that's the user
- Group emails (`group.foo@...`)

For each remaining attendee:
1. Lowercase firstname → `people/<firstname>`
2. If firstname collides with someone already in the user's graph (different person, same firstname), use `people/<firstname>-<lastname-initial-or-full>`. Example collision: `Alice Smith` vs `Alice Lin` → `people/alice` and `people/alice-l`.
3. Check the existing `people/*` namespace via `list_pages` to detect collisions and reuse existing pages.
4. If page doesn't exist, create it as a stub:
   ```yaml
   tags: system
   exclude-from-graph-view: true
   company: 
   role: 
   ```
   If you can infer the company from the attendee's email domain (e.g. `@stripe.com` → `[[companies/stripe]]`, internal domain → `[[acme]]`), set `company::` accordingly. The user can flesh it out later.

### 3. Compute journal page name

Logseq journal format: `<MonAbbr> <D><ordinal>, <YYYY>`.

- Months: Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec
- Ordinals: 1st, 2nd, 3rd, 4th–20th use "th", 21st, 22nd, 23rd, 24th–30th use "th", 31st use "st"

Examples: `Jun 12th, 2026`, `Jan 1st, 2026`, `Mar 23rd, 2025`.

### 4. Idempotency check

Before writing, check the journal page for an existing meeting block with the same title. If a `[[meetings]] {Title}` block already exists on that journal date, ask the user whether to skip or overwrite.

### 4a. Scan summary for durable rules — REQUIRED

Meeting summaries often contain durable knowledge buried in the discussion: decisions made, system rules clarified, debugging insights shared. These should be **surfaced** at the top of the meeting block, not buried in the summary markdown.

**Strong rule signals (extract if present):**
- "We decided X" / "Going forward, X" — durable decision
- "By design, X works like Y" — system rule
- "The rule is X" / "X always means Y" — explicit rule statement
- Explicit "Decision:" / "Agreement:" / "Conclusion:" markers in the summary
- Trade-off comparisons with a chosen path

**Skip these (not durable rules):**
- Routine status updates ("Bob deployed X")
- In-progress work ("working on Y")
- Personal opinions without group agreement ("I think X")
- Discussion items without resolution

When strong rule signals are detected, **add a `## Key insights` section as the FIRST child** of the meeting block, with topic-page references on the title line. When no rule signals exist, skip the section.

### 5. Write the journal block

For each meeting, append one block to the journal page (mode=append). When syncing multiple meetings same day, **order chronologically ascending** (earliest first) so the journal reads top-to-bottom through the day. **Add an empty block between meetings** as a visual separator.

**CRITICAL formatting (same as logseq-note skill):** put hub references INLINE on the title line, NOT as a `tags::` property. The mcp-logseq parser does not associate inline `tags::` lines with the parent bullet — it creates separate phantom child blocks. Use `[[reference]]` syntax inline instead.

Block format (with rule signals detected):

```markdown
- [[meetings]] {Title} — {HH:MM} — [[meetings]] [[<work-hub>]] [[<work-hub>/<topic-1>]] [[<work-hub>/<topic-2>]]
  - ## Key insights
    - <rule 1, terse, like a note not docs>
    - <rule 2>
  - attendees:: [[people/x]], [[people/y]]
  - ## Summary
    - {summary content, preserved}
  - ## Action items
    - TODO {action item assigned to user}
    - {action item assigned to someone else}
-

- [[meetings]] {Next meeting title}
  ...
```

Block format (no rule signals, plain meeting):

```markdown
- [[meetings]] {Title} — {HH:MM} — [[meetings]] [[<work-hub>]]
  - attendees:: [[people/x]], [[people/y]]
  - ## Summary
    - {summary content, preserved}
  - ## Action items
    - TODO {action item assigned to user}
    - {action item assigned to someone else}
```

Notes:
- **Hub references inline on title.** Always include `[[meetings]]`. Add `[[<work-hub>]]` based on attendee email domain. Add `[[<work-hub>/<topic-X>]]` for each topic surfaced in step 4a's rule extraction — this is what makes the rule findable later via topic hubs.
- **Action items: TODO only if the user owns the item.** If the parenthetical assignee includes the user's first name (e.g. `(Alice)` or `(Alice + Bob)`, assuming the user is "Alice") or there's no assignee, prefix with `TODO`. If assigned to someone else only (e.g. `(Bob)`, `(Charlie)`), leave as plain bullet. Don't pollute the user's TODO list with other people's work.
- **Attendees as a child bullet, not a property.** `- attendees:: [[people/x]]` is a child block whose content includes attendee references. This still creates backlinks (entity-aggregator pattern) but works around the MCP parser bug.
- **No `tags::` property line, no tool-specific ID properties.** Match by title + date for idempotency.
- **No source attribution.** Don't add "synced from Granola" or "imported from Otter" lines. Just the meeting content.

### 6. Confirm

Report concisely:

```
Synced N meetings to [[Jun 12th, 2026]]:
- {title 1} ({HH:MM}) — N attendees
- {title 2} ({HH:MM}) — N attendees
{K people stubs created}
```

## Entity-aggregator patterns (do follow)

- **Entity is the aggregator.** Each meeting is one block in that day's journal. The attendee link does the grouping automatically — open `people/<person>` to see every meeting with them. No "series" page needed for recurring 1:1s.
- **One block per occurrence.** Don't merge weekly stand-ups into one page. Each day's stand-up is its own block in that day's journal.

## Hard constraints

- **Default to journal blocks, not dedicated pages.** Only create a separate page if the user explicitly asks.
- **No transcript dumping.** The tool's summary is the source of truth. Never pull raw transcripts.
- **No source attribution.** No "synced from X" lines, no tool-specific ID properties. Just the meeting content.
- **Strip formatting artifacts.** Tools often add escape characters (e.g. `\~30 minutes` → `~30 minutes`). Clean them.
- **TODO discipline.** Only the user's own action items become TODOs. Everyone else's work stays as plain text bullets.

## Worked example

**Input:** `/meeting-sync 2026-06-12` — found 3 meetings

**Example A — meeting with rule signals detected** (user is "Alice"; teammates Bob, Charlie):

```markdown
- [[meetings]] Team Standup — 13:30 — [[meetings]] [[<work-hub>]] [[<work-hub>/<topic>]]
  - ## Key insights
    - <rule extracted from discussion, terse, note voice>
    - <another rule if surfaced>
  - attendees:: [[people/bob]], [[people/charlie]]
  - ## Summary
    - ### <work area> update (Bob)
      - PR merged and deploying, live shortly
      - Next: extend to <next area>
    - ...
  - ## Action items
    - TODO Retest <feature> end-to-end (Bob + Alice, in ~1 hour)
    - Deploy <feature> to <env> once current build is live (Bob)
    - TODO Help Charlie parallelize <task> (Alice)
```

The `Key insights` section surfaces durable rules at the TOP of the meeting block, so they're visible without scrolling through the summary. The topic-page reference (`[[<work-hub>/<topic>]]`) on the title makes those insights findable on the topic hub later.

**Example B — meeting with no rule signals** (routine sync, no decisions):

```markdown
- [[meetings]] Daily standup — 09:30 — [[meetings]] [[<work-hub>]]
  - attendees:: [[people/bob]], [[people/charlie]]
  - ## Summary
    - {summary as-is}
  - ## Action items
    - TODO {item}
-

- [[meetings]] {Next meeting...}
```

No `Key insights` section, no topic-page tag — most meetings are like this. Don't force rule extraction when the meeting was just status updates.

**TODO discipline:** Bob-only items are plain bullets; Alice-owned (or shared) items are `TODO`. The empty `-` between meeting blocks gives visual separation in Logseq.

**People stubs created:** `people/bob`, `people/charlie` (created as needed; existing pages reused).

## Don't

- Don't pull raw transcripts — never needed
- Don't auto-link group emails (`group.web-squad-1@...`)
- Don't create top-level pages like `Squad 1 Stand Up 2026-06-12` — keep meetings in journal blocks
- Don't include the meeting creator/host attendee — that's the user themselves
- Don't tag the journal page itself — tag the meeting block via inline `[[references]]` on the title
- Don't backfill old meetings without being asked
- Don't add tool-specific metadata properties to the block
