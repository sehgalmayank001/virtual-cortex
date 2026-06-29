---
name: meeting-sync
description: Sync meetings from any transcript tool (Granola, Otter, Fireflies, Fathom, tl;dv, etc.) into the Logseq journal entry for each meeting's date. Inserts a structured meeting block per meeting tagged with same-block properties (tags::, type::, attendees::), scans the summary for durable rules and surfaces them in a Key insights section, auto-links attendees to people/<firstname> pages (creates stubs if missing). Defaults to most recent meeting; accepts a date or title arg. Use when the user says "sync meetings", "/meeting-sync", "import meeting", "save meeting to logseq", or similar.
---

# Meeting Sync

Pulls meetings from the user's transcript/summary tool and writes them to the corresponding day's Logseq journal as structured meeting blocks. Each meeting block carries its tags and metadata as **same-block properties** (`tags::`, `type::`, `attendees::`) written directly under the title line — exactly like the `/template meeting` output. The tool's AI summary IS the meeting note — don't pull raw transcripts.

**Two things the properties do:**

- **`tags:: [[meetings]]`** groups the note — it's what lands under the **All meetings** view (and `[[<work-hub>]]` puts it on the work hub too).
- **`type::`** facets it — the **1:1s** and **Interviews** views query `(property type "1on1")` / `(property type interview)`, so a meeting only appears under a facet if it carries the matching `type::`.

**Values:** `type::`/`status::` are scalar — write them bare (`type:: 1on1`). `tags::`/`attendees::` hold page references. If a freshly written note doesn't show on its hub, re-index the graph once (Logseq graph menu → Re-index) — API/file writes can lag Logseq's live index.

The skill also scans the summary for durable rules (system behaviour decisions, debugging insights, agreements) and surfaces them in a `## Key insights` section at the top of the meeting block, adding the topic page to `tags::` so the rule is findable on the topic hub later.

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
4. If page doesn't exist, create it as a stub with these page properties:
   ```
   tags:: system
   exclude-from-graph-view:: true
   company:: 
   role:: 
   ```
   If you can infer the company from the attendee's email domain (e.g. `@stripe.com` → `[[companies/stripe]]`, internal domain → `[[acme]]`), set `company::` accordingly. The user can flesh it out later.

### 3. Compute journal page name

Logseq journal format: `<MonAbbr> <D><ordinal>, <YYYY>`.

- Months: Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec
- Ordinals: 1st, 2nd, 3rd, 4th–20th use "th", 21st, 22nd, 23rd, 24th–30th use "th", 31st use "st"

Examples: `Jun 12th, 2026`, `Jan 1st, 2026`, `Mar 23rd, 2025`.

### 4. Idempotency check

Before writing, check the journal page for an existing meeting block with the same title. If a meeting block with that title (carrying `tags:: [[meetings]]`) already exists on that journal date, ask the user whether to skip or overwrite.

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

When strong rule signals are detected, **add a `## Key insights` section as the FIRST child** of the meeting block, and add the topic page(s) to the block's `tags::`. When no rule signals exist, skip the section.

### 5. Write the journal block

For each meeting, append one block to the journal page (mode=append). When syncing multiple meetings same day, **order chronologically ascending** (earliest first) so the journal reads top-to-bottom through the day. **Add an empty block between meetings** as a visual separator.

**Formatting:** write the tags and metadata as **same-block properties** — un-dashed `key:: value` lines directly under the title bullet — so they attach to the parent (title) block. Do not put them on dashed child bullets — that makes them separate blocks. In `tags::` and `attendees::`, every value is a `[[bracketed]]` reference; scalar values like `type::` stay bare.

Block format (with rule signals detected):

```markdown
- {Title} — {HH:MM}
  type:: 1on1
  attendees:: [[people/x]], [[people/y]]
  tags:: [[meetings]], [[<work-hub>]], [[<work-hub>/<topic-1>]], [[<work-hub>/<topic-2>]]
  - ## Key insights
    - <rule 1, terse, like a note not docs>
    - <rule 2>
  - ## Summary
    - {summary content, preserved}
  - ## Action items
    - TODO {action item assigned to user}
    - {action item assigned to someone else}
-

- {Next meeting title} — {HH:MM}
  ...
```

Block format (no rule signals, plain meeting):

```markdown
- {Title} — {HH:MM}
  attendees:: [[people/x]], [[people/y]]
  tags:: [[meetings]], [[<work-hub>]]
  - ## Summary
    - {summary content, preserved}
  - ## Action items
    - TODO {action item assigned to user}
    - {action item assigned to someone else}
```

Notes:
- **`tags::` does the grouping.** Always include `meetings`. Add `<work-hub>` based on attendee email domain. Add `<work-hub>/<topic-X>` for each topic surfaced in step 4a's rule extraction — this is what makes the rule findable later via topic hubs.
- **`type::` does the faceting — REQUIRED for 1:1s and interviews.** Classify the meeting and set `type::` so it lands under the right facet on the meetings hub:
  - **`1on1`** — exactly one counterpart (you + one other person), reads like a recurring/individual catch-up. Single-name titles ("Alice 1:1", "Catch-up with Bob") are strong signals.
  - **`interview`** — a candidate evaluation. Title or context names a candidate/role.
  - **generic meeting** (standups, group syncs, planning) — omit `type::`; it still shows under All meetings, just not a facet. Optionally set a value the `meetings` hub lists under `type-values::` (e.g. `standup`, `sync`).

  Write the value bare — `type:: 1on1`. The leading digit only needs quoting on the *query* side (`(property type "1on1")`), which the hub already does; the stored property value is the plain string.
- **`attendees::` aggregates by person.** Comma-separated `[[people/x]]` references. Backlinks on each person page surface every meeting with them (entity-aggregator pattern) — no "series" page needed.
- **Action items: TODO only if the user owns the item.** If the parenthetical assignee includes the user's first name (e.g. `(Alice)` or `(Alice + Bob)`, assuming the user is "Alice") or there's no assignee, prefix with `TODO`. If assigned to someone else only (e.g. `(Bob)`, `(Charlie)`), leave as plain bullet. Don't pollute the user's TODO list with other people's work.
- **No tool-specific ID properties, no source attribution.** Match by title + date for idempotency. Don't add "synced from Granola" lines.

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
- **Tag and facet via same-block properties.** `tags:: [[meetings]]` (+ `[[<work-hub>]]`/topics, all bracketed) groups; `type:: 1on1`/`interview` (bare) facets. Write them as un-dashed lines directly under the title so they attach to the parent block. Generic meetings need no `type::`.

## Worked example

**Input:** `/meeting-sync 2026-06-12` — found 3 meetings

**Example A — meeting with rule signals detected** (user is "Alice"; teammates Bob, Charlie):

```markdown
- Team Standup — 13:30
  attendees:: [[people/bob]], [[people/charlie]]
  tags:: [[meetings]], [[<work-hub>]], [[<work-hub>/<topic>]]
  - ## Key insights
    - <rule extracted from discussion, terse, note voice>
    - <another rule if surfaced>
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

The `Key insights` section surfaces durable rules at the TOP of the meeting block, so they're visible without scrolling through the summary. The topic page in `tags::` (`<work-hub>/<topic>`) makes those insights findable on the topic hub later. This standup is a group meeting, so no `type::` — it shows under All meetings only.

**Example B — a 1:1 (faceted)** (user is "Alice", meeting with Bob):

```markdown
- Alice / Bob 1:1 — 10:00
  type:: 1on1
  attendees:: [[people/bob]]
  tags:: meetings, <work-hub>
  - ## Summary
    - {summary as-is}
  - ## Action items
    - TODO {item}
-

- {Next meeting...} — {HH:MM}
```

`type:: 1on1` lands this under the **1:1s** facet on the meetings hub as well as All meetings. Most group meetings have no `type::` — don't force one.

**TODO discipline:** Bob-only items are plain bullets; Alice-owned (or shared) items are `TODO`. The empty `-` between meeting blocks gives visual separation in Logseq.

**People stubs created:** `people/bob`, `people/charlie` (created as needed; existing pages reused).

## Don't

- Don't pull raw transcripts — never needed
- Don't auto-link group emails (`group.web-squad-1@...`)
- Don't create top-level pages like `Squad 1 Stand Up 2026-06-12` — keep meetings in journal blocks
- Don't include the meeting creator/host attendee — that's the user themselves
- Don't tag the journal page itself — tag the meeting block via its `tags::` property
- Don't put `tags::`/`type::`/`attendees::` on dashed child bullets — keep them as un-dashed lines under the title so they attach to the parent block
- Don't backfill old meetings without being asked
- Don't add tool-specific metadata properties to the block
