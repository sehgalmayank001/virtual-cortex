---
name: virtual-cortex-setup
description: Full guided setup of the Virtual Cortex (the Logseq Knowledge System) — verifies MCP connection, scans the existing graph, creates hub pages, templates, slash commands, and a company/project hub. Combines MCP verification with graph-init into one command. Use when the user says "set up my virtual cortex", "/virtual-cortex-setup", "set up logseq", "install the knowledge system", "get started", or they just bought/downloaded the bundle and want to go.
---

# Virtual Cortex Setup

One command to go from "I just downloaded this bundle" to "the Virtual Cortex is running." Verifies the MCP connection, scans the graph, and scaffolds everything.

## How to invoke

- `/virtual-cortex-setup` — full guided setup
- Natural: "set up my virtual cortex", "set up my graph", "get started", "install the knowledge system"

## Prerequisites

The user must have:
- Logseq desktop running
- The mcp-logseq MCP server configured (see skills/README.md for instructions), version ≥ 1.7.0 (older versions mis-parse the templates' same-block properties)
- The Logseq HTTP API enabled and running

## Bundled files

This skill builds pages from ready-made files that ship **inside the bundle, in an `assets/` folder that sits next to the skills** — a sibling of this skill's own directory. After the standard install (`cp -r skills/* ~/.claude/skills/`) they live at `<your-skills-dir>/assets/` (e.g. `~/.claude/skills/assets/`).

Whenever a step says `assets/pages/<hub>.md`, `assets/templates.md`, or `assets/config.edn`, read it from that bundled `assets/` folder. Never hand-write the content from memory, and never look inside the user's graph for it. If you cannot locate the folder, ask the user where they unpacked the bundle rather than improvising the file contents — improvising is how the hubs and templates silently drift from the shipped, correct versions.

## Steps

### 1. Verify the MCP connection

Call `mcp__mcp-logseq__list_pages` with no arguments.

**If it works:** report the page count and move to Step 2.

```
Connected to your Logseq graph. Found N pages.
```

**If it fails:** stop and troubleshoot. Walk the user through:

```
Can't connect to your Logseq graph. Let's fix that:

1. Is Logseq running? (open it if not)
2. Is the HTTP API enabled? Settings → Features → "Enable HTTP APIs server"
3. Is the API server started? Click the plug icon → "Start server"
4. Do you have an API token? API panel → "Authorization tokens" → create one
5. Is mcp-logseq configured? Check your agent's MCP config for the token and URL.

Fix whichever step failed and try /virtual-cortex-setup again.
```

Do not proceed until the connection works.

### 2. Scan existing pages

Use the page list from Step 1 to categorise what exists:

**Detect existing hubs** — check if any of these pages already exist:
- `meetings`, `brag`, `decisions`, `incidents`, `books`, `people`, `companies`

**Detect existing tags** — look for pages that match common tag patterns:
- Meeting-like: `standup`, `stand-up`, `sync`, `1:1`, `1on1`, `retro`, `retrospective`, `planning`
- Brag-like: `wins`, `shipped`, `accomplishments`, `achievements`, `highlights`
- Decision-like: `decision`, `decisions`, `adr`, `rfc`
- Incident-like: `incident`, `outage`, `postmortem`, `post-mortem`
- Book-like: `books`, `reading`, `book-notes`, `reading-list`

**Detect project/company namespaces** — pages containing `/` that look like project hubs.

**Detect people pages** — pages under `people/` namespace.

### 3. Present the plan

Show what you'll create and what already exists:

```
Here's what I found and what I'd set up:

Already exists:
  ✓ meetings hub (with 12 tagged entries)
  ✓ people/ namespace (8 people pages)

Will create:
  □ brag hub
  □ decisions hub
  □ incidents hub
  □ books hub
  □ companies hub
  □ templates page (8 templates)

Existing tags to merge into hub queries:
  #standup, #retro → will be included in the meetings hub query
  #shipped → will be included in the brag hub query

Questions:
  1. What's your current project/company called? (e.g. acme, widget-co)
  2. Which of the hubs above do you want? (all / pick from list)

Reply and I'll build it.
```

Wait for the user to respond.

### 4. Create hub pages

**The bundle ships ready-made hub pages in `assets/pages/` — use these as the source of truth.** There is one file per hub: `meetings.md`, `brag.md`, `decisions.md`, `incidents.md`, `books.md`, `people.md`, `companies.md`. Each is already in Logseq's native format with the correct `icon::` page property, heading, and query.

For each confirmed hub:

1. Read the matching file from `assets/pages/<hub>.md`.
2. Create the page with `mcp__mcp-logseq__create_page`, using the file content verbatim.

This keeps the AI route and the manual route (`01b-setup-manual.md`) identical — never hand-write the hub format inline, always read it from the file.

**Hubs and their files** — create each from the file verbatim. The file is the source of truth for its `icon::`, heading, query and any sub-views, so don't restate them here:

- `meetings` → `assets/pages/meetings.md`
- `brag` → `assets/pages/brag.md`
- `decisions` → `assets/pages/decisions.md`
- `incidents` → `assets/pages/incidents.md`
- `books` → `assets/pages/books.md`
- `people` → `assets/pages/people.md`
- `companies` → `assets/pages/companies.md`

Every hub query carries a `(not (page [[hub]]))` clause so the hub never lists itself, and some files add filtered sub-views (meetings → 1:1s/Interviews, incidents → Open/Resolved, books → Reading/Read/To read). Creating from the file verbatim preserves all of it — that's the whole job.

**Optional hubs:** the bundle also ships `assets/pages/learning.md` and `assets/pages/career.md`. Offer these only if the user's existing tags or stated workflow suggest they'd use them — don't create them by default.

**Merged queries for existing tags:** if the user has existing tags that map to a hub (from Step 2), don't rewrite the page — take the hub's file and swap only its first query line for a merged `or` query, keeping the self-exclusion. For `meetings`:

```
{{query (and (or [[meetings]] [[standup]] [[retro]] [[1:1]]) (not (page [[meetings]])))}}
```

Skip any hub the user already has or said they don't want.

**Tag stubs from merged tags:** If merged queries include the user's old tag names (`standup`, `retro`, etc.), those old tag pages remain as stubs. Apply these properties to each:

```
tags:: system
exclude-from-graph-view:: true
```

Don't apply these to hub pages — hubs have icons and queries and should be visible.

### 5. Create the project hub

Read the starter file `assets/pages/your-project.md`, then replace every `your-project` with the project name the user gave in Step 3, and create the page with `mcp__mcp-logseq__create_page` under that name. The result should look like this (for a project called `<project>`):

```markdown
icon:: 🏢

- ## All tagged
	- {{query (and [[<project>]] (not (page [[<project>]])))}}
- ## Sub-topics
	- {{query (and (namespace [[<project>]]) (not (page [[<project>]])))}}
```

### 6. Create the templates page

`assets/templates.md` is the source of truth for the template set (meeting, 1on1, interview, brag, decision, book-note, incident, strikedoc). Read it and use its content verbatim — never hand-write the templates inline.

- **`templates` page doesn't exist:** create it with the full content of `assets/templates.md`.
- **Already exists:** read its content, compare against `assets/templates.md`, show which templates are missing, and offer to append only those.

Each template's first line is a placeholder headline in parentheses on the parent block (angle brackets render as HTML in Logseq, so parentheses are used). The properties (`template::`, `type::`, `tags::`, etc.) sit on that same placeholder block as consecutive un-dashed `key:: value` lines, so they attach to the headline. Only the `## sections` are dashed child blocks beneath it. The user overwrites the placeholder with a title so the entry isn't untitled on its hub. Preserve that structure exactly when creating the page.

After creating the page, fetch it back once with `mcp__mcp-logseq__get_page_content` and spot-check one template: the placeholder block (its content starts with `(`) should carry its `template::` and the other properties on the block itself, not as separate child blocks. mcp-logseq ≥ 1.7.0 parses same-block properties correctly, so this should just pass. (Older servers ≤ 1.6.3 mis-parsed un-dashed property lines into separate blocks — if you ever see that, the fix is to upgrade mcp-logseq.)

### 7. Show slash command instructions

The agent cannot edit `config.edn` directly. Show the user exactly what to paste:

```
Last step — paste these slash commands into your logseq/config.edn file.

Find the :commands line and replace it with:

:commands
[
 ["attendees" "attendees:: "]
 ["type"      "type:: "]
 ["tags"      "tags:: "]
 ["status"    "status:: "]
 ["impact"    "impact:: "]
 ["evidence"  "evidence:: "]
 ["severity"  "severity:: "]
 ["why"       "why:: "]
 ["context"   "context:: "]
 ["role"      "role:: "]
 ["author"    "author:: "]
]

Save the file and restart Logseq.
```

### 8. Confirm and test

```
Virtual Cortex setup complete:

  ✓ MCP connection verified
  ✓ Hub pages created: meetings, brag, decisions, incidents, books, people, companies, <project>
  ✓ Templates page: 8 templates ready (all properties verified on their placeholder blocks)
  ✓ Slash commands: paste the block above into config.edn, then restart Logseq

Your existing tags (#standup, #retro, etc.) are included in the hub queries.
New content: run /template <type> for structured notes, or type #tag inline.

To test: restart Logseq, then type /template meeting in today's journal.

Next steps:
  - Read 02-mental-model.md to understand the 3-tier system
  - Read 03-powertags.md for worked examples of each template
  - Try /brag-finder to surface wins you've already written but didn't tag
```

## Hard constraints

- **Verify MCP first.** Don't attempt any writes until the connection is confirmed.
- **Show the plan before writing.** Never create pages without the user seeing and confirming the list.
- **Don't overwrite existing pages.** If a hub already exists, skip it. If templates exist, append only what's missing.
- **Don't touch config.edn.** Always tell the user what to paste manually.
- **Don't create namespace sub-pages.** Only top-level hubs. Sub-topics emerge from usage.
- **Don't assume all 8 powertags.** Ask which ones the user wants.

## Edge cases

- **Brand new graph (0 pages):** Skip the scan. Create all hubs + templates. Simple.
- **User doesn't know their project name yet:** Skip the project hub. Tell them to run `/virtual-cortex-setup` again or create it manually later.
- **Templates page exists with some templates:** Show a diff of what's missing. Offer to append.
- **MCP works but returns 0 pages:** Logseq graph might be empty or the wrong graph is open. Ask the user to check which graph is active.
- **User wants to rename existing tags:** Defer to `/graph-init` which handles the rename flow. This skill focuses on scaffolding, not migration.

## Don't

- Don't silently create pages
- Don't modify existing hub pages
- Don't edit journal entries
- Don't create people pages (those emerge from meeting tagging)
- Don't create company sub-pages (those emerge from usage)
- Don't run longer than needed — this is a one-shot setup, not an ongoing skill
