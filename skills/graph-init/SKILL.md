---
name: graph-init
description: Bootstrap the Logseq Knowledge System on an existing graph. Scans pages, discovers tags already in use, maps them to powertags, and scaffolds hub pages and slash commands. Use when the user says "set up my graph", "/graph-init", "bootstrap logseq", "init knowledge system", or they just installed the bundle and want to get started.
---

# Graph Init

The existing-graph path: scans what's already there, maps your current tags to the bundle's powertags, and offers to keep, rename, or adapt them. It then scaffolds the missing pieces using the same source files as `/virtual-cortex-setup` (`assets/pages/`, `assets/templates.md`, `assets/config.edn`).

Use `/virtual-cortex-setup` if you want the full guided run including the MCP connection check; use `/graph-init` when you're already connected and the priority is mapping existing content. The tag-migration strategies (rename/adapt) live here.

## How to invoke

- `/graph-init` — full scan + setup
- Natural: "set up my graph", "bootstrap logseq", "initialise the knowledge system"

## Bundled files

This skill builds pages from ready-made files that ship **inside the bundle, in an `assets/` folder that sits next to the skills** — a sibling of this skill's own directory. After the standard install (`cp -r skills/* ~/.claude/skills/`) they live at `<your-skills-dir>/assets/` (e.g. `~/.claude/skills/assets/`).

Whenever a step says `assets/pages/<hub>.md`, `assets/templates.md`, or `assets/config.edn`, read it from that bundled `assets/` folder. Never hand-write the content from memory, and never look inside the user's graph for it. If you cannot locate the folder, ask the user where they unpacked the bundle rather than improvising the file contents.

## Steps

### 1. Scan the existing graph

Use `mcp__mcp-logseq__list_pages` to get all pages in the graph.

Categorise every page into buckets:

**Journal pages** — pages matching date patterns (e.g. `Jun 13th, 2026`). Skip these for now.

**Likely tag pages** — pages that are referenced by other pages but have no content themselves. These are existing tag stubs.

**Content pages** — pages with actual content blocks.

**Namespace pages** — pages containing `/` (e.g. `work/onboarding`). Note the parent namespaces.

### 2. Discover existing tags and patterns

From the page list, identify tags the user already uses. Look for common patterns:

**Meeting-like tags:**
`standup`, `stand-up`, `sync`, `1:1`, `1on1`, `one-on-one`, `retro`, `retrospective`, `planning`, `sprint`, `weekly`, `all-hands`, `check-in`

**Brag-like tags:**
`wins`, `shipped`, `accomplishments`, `achievements`, `done`, `completed`, `highlights`

**Decision-like tags:**
`decision`, `decisions`, `adr`, `rfc`, `tech-decision`

**Incident-like tags:**
`incident`, `outage`, `postmortem`, `post-mortem`, `bug-report`, `fire`, `sev1`, `sev2`

**Book-like tags:**
`books`, `reading`, `book-notes`, `reading-list`

**People-like patterns:**
Pages under a `people/` namespace, or pages named after people (first names, full names)

**Project/company patterns:**
Pages under a company namespace, or tags that look like project names (often the most-referenced non-system tags)

### 3. Present findings to the user

Show what you found. Don't write anything yet.

```
Scanned your graph: N pages total.

Existing tags I found that map to this system's powertags:

  Meeting-like:  #standup, #retro, #1:1 (N references)
  Brag-like:     #shipped, #wins (N references)
  Decision-like: (none found)
  Incident-like: #postmortem (N references)
  Book-like:     #reading-list (N references)

Project/company namespaces: work/, acme/

People pages: people/alice, people/bob (or: no people/ namespace found)

What's missing (I can create these):
  - Hub pages: meetings, brag, decisions, incidents, books, people, companies
  - Templates page
  - Property shortcut commands in config.edn
  - Company/project hub for: <detected project>

How would you like to handle your existing tags?
  1. Keep them as-is and add the bundle's tags alongside (recommended if you have history)
  2. Rename existing tags to match the bundle's conventions
  3. Adapt the bundle's tag names to match yours
```

Wait for the user to respond before proceeding.

### 4. Handle existing tags based on user's choice

**Option 1 — Keep existing, add alongside (recommended):**

Existing tags stay untouched. Don't rewrite the hub page — just take the hub's asset file and replace its first query line with a merged `or` query that adds the user's tags, keeping the `(not (page [[hub]]))` self-exclusion so the hub never lists itself. For `meetings`:

```
{{query (and (or [[meetings]] [[standup]] [[retro]] [[1:1]]) (not (page [[meetings]])))}}
```

Everything else in the file (icon, headings, sub-views) stays as-is. Old content stays findable, new content uses the new conventions, no migration needed.

**Option 2 — Rename existing to match bundle:**

Warn the user: "This will rename N pages. Logseq handles link updates automatically, but this is a one-way operation. Proceed?"

If confirmed, use `mcp__mcp-logseq__update_page` to update `tags::` properties on affected pages. Rename tag stub pages.

**Option 3 — Adapt bundle to match user's tags:**

Use the user's existing tag names in the hub queries, templates, and slash commands. Rewrite the templates page with their naming conventions.

### 5. Scaffold from the bundle's source files

Create everything from the bundle's ready-made files — never hand-write hub or template content inline. These files are the single source of truth for both this skill and `/virtual-cortex-setup`, so the AI route and the manual route stay identical:

- **Hubs:** for each confirmed hub, read `assets/pages/<hub>.md` and create the page verbatim (`meetings`, `brag`, `decisions`, `incidents`, `books`, `people`, `companies`). For Option 1 (kept tags), swap only the first query line for the merged `or` query from Step 4, keeping the `(not (page [[hub]]))` self-exclusion. Preserve each file's filtered sub-views (meetings → 1:1s/Interviews, incidents → Open/Resolved, books → Reading/Read/To read).
- **Project hub:** read `assets/pages/your-project.md`, replace every `your-project` with the detected or declared project name, and create it. If no project was detected, ask for the name first.
- **Templates:** create the `templates` page from `assets/templates.md` verbatim. If it already exists, append only the missing templates. (Requires mcp-logseq ≥ 1.7.0, which parses the templates' same-block properties correctly.)
- **Config:** tell the user to paste the `:commands` block from `assets/config.edn` (property shortcuts only — no tag commands). The agent can't edit `.edn` files directly.

**Tag stubs from merged tags:** if Option 1 kept old tag names (`standup`, `retro`, etc.), those stub pages remain. Mark each so they don't clutter the graph view (never apply this to hubs, which should stay visible):

```
tags:: system
exclude-from-graph-view:: true
```

### 6. Confirm setup

```
Setup complete:

  Created hubs: meetings, brag, decisions, incidents, books, people, companies, <project>
  Templates page: created (8 templates)
  Config: told you what to paste into config.edn

  Your existing tags (#standup, #retro, etc.) are still working.
  New content: run /template <type> for structured notes, or type #tag inline.
  Hub queries include both old and new tags.

  One-time re-index: pages and tag stubs written through the API don't always
  register their references in Logseq's live index until you re-index. Open the
  graph menu (top-right ⋯ → "Re-index") once now so the new hubs, renamed tags,
  and stub properties resolve. Only needed after a bulk write like this.

  Next: restart Logseq to load the property shortcut commands.
  Then try: /template meeting in today's journal.
```

## Hard constraints

- **Ask first, write second.** Never create pages without showing the plan and getting confirmation.
- **Don't delete existing pages.** Even if they're tag stubs. The user's history matters.
- **Don't rename without explicit permission.** Option 2 is destructive. Always warn.
- **Don't touch config.edn directly.** Tell the user what to paste. The MCP can't safely edit `.edn` files.
- **Don't pre-create namespace sub-topics.** Only create top-level hubs. Sub-topics emerge from usage.

## Edge cases

- **Brand new graph (no pages):** Skip the scan. Go straight to creating all hubs and the templates page from the asset files, plus the config block. Tell the user it's a clean start.
- **Graph with 1,000+ pages:** The scan may take time. Do it in batches. Don't try to categorise every page — focus on finding tag patterns.
- **User has a templates page already:** Don't overwrite. Append missing templates only.
- **User's existing tags are close but not exact matches** (e.g. `post-mortem` vs `postmortem`): Surface these as "possible matches" and let the user decide.
- **Multiple projects/companies detected:** Create a hub for each. Ask the user which is their current/primary one.

## Don't

- Don't create pages the user didn't agree to
- Don't silently merge or rename tags
- Don't create empty sub-namespace pages ("you'll need these later")
- Don't modify journal entries
- Don't add `exclude-from-graph-view` to pages the user actively uses
- Don't assume the user wants all 8 powertags — ask which ones they actually use
