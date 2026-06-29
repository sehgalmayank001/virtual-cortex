# Manual setup (~15 min)

No AI agent, no MCP server, no terminal. You drop a few ready-made files into your graph, paste one config block, and you are done. Everything here uses native Logseq features only.

If you would rather have an AI agent scan your graph and build this for you, see [01a-setup-ai.md](01a-setup-ai.md) instead. Both paths reach the same end state.

## Prerequisites

- Logseq installed (desktop version)
- A graph you are willing to add pages to (brand new or existing, this is purely additive)
- Ability to open and save a text file (`logseq/config.edn`)

## Step 1 — Find your graph folder (1 min)

Your graph lives on disk. In Logseq:

1. Click the graph dropdown (top left)
2. Note the path next to the graph name, that is the folder
3. Inside that folder, you will see `logseq/`, `pages/`, `journals/`, and `assets/`

Open that folder in Finder / Explorer.

## Step 2 — Add slash commands to `config.edn` (2 min)

Open `<your-graph>/logseq/config.edn` in any text editor. Find the line that says:

```
:commands []
```

Replace it with the contents of [`assets/config.edn`](assets/config.edn) from this bundle:

```clojure
:commands
[
 ;; Property shortcuts.
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
```

Save the file. **Restart Logseq**, `:commands` only loads on startup.

Test it: in any block, type `/attendees`. You should see `attendees:: ` appear. If nothing happens, double check you saved the file and fully restarted (not just closed the window).

## Step 3 — Create the hub pages (2 min)

A hub page is a single place that gathers everything you have tagged with a given powertag. It holds an `icon::` (so it is easy to spot) and a live `{{query ...}}` that auto lists every block carrying that tag. You tag a meeting with `meetings`, and it shows up on the `meetings` hub, no manual filing.

You need one hub per powertag, and the bundle already ships all seven in [`assets/pages/`](assets/pages/), each a finished page in Logseq's own file format:

| File | Hub | Collects |
|------|-----|----------|
| `meetings.md` | 📅 meetings | every meeting, 1:1, and interview |
| `brag.md` | 🏆 brag | wins and accomplishments |
| `decisions.md` | 🧭 decisions | decisions with their rationale |
| `books.md` | 📖 books | book notes and reading |
| `incidents.md` | 🚨 incidents | incidents and postmortems |
| `people.md` | 👥 people | everyone in your `people/` namespace |
| `companies.md` | 🤝 companies | external vendors, customers, partners |

Because they are real Logseq page files, you do not recreate them inside the app, you drop them straight into your graph on disk and Logseq picks them up:

1. Open your graph folder (the one you found in Step 1) in Finder / Explorer, then open its `pages/` directory, this is where Logseq stores every page as a `.md` file.
2. Copy all seven `.md` files from this bundle's `assets/pages/` into that `pages/` folder.
3. Switch back to Logseq. The hubs show up in your page list right away, each with its icon and query already in place. Nothing to type, no blocks to split, no "paste as code" mishaps.

The hubs will look empty at first, that is expected. The queries have nothing to list until you start tagging content, then they fill in on their own.

**People pages link to where they belong.** When you create a person page (e.g. `people/Bob`), add a `company::` property to connect them:

```
# Page name: people/bob
company:: [[acme]]
role:: backend engineer
```

For external contacts:

```
# Page name: people/sarah
company:: [[companies/stripe]]
role:: account manager
```

This makes the connection queryable. Open `acme` and you see every meeting, decision, and brag tagged with acme, including the ones involving Bob. Open `people/bob` and you see every meeting with him via backlinks. Open `companies/stripe` and you see Sarah's meetings there too.

Three hubs, one person, zero duplication. The `company::` property is the link between them.

### Your company/project hub (do this now)

The powertag hubs above are universal. But most of your notes will also belong to a specific project or company. Set that up now.

The bundle ships a starter file for this: [`assets/pages/your-project.md`](assets/pages/your-project.md). Because the page name has to match your project's tag, you rename the file and swap the placeholder before dropping it in:

1. Decide what you call your project internally (e.g. `acme`, `widget-co`).
2. Rename `your-project.md` to that name (e.g. `acme.md`).
3. Open it and replace every `your-project` with that same name. The file should end up like this:

```
icon:: 🏢

- ## All tagged
	- {{query (and [[acme]] (not (page [[acme]])))}}
- ## Sub-topics
	- {{query (and (namespace [[acme]]) (not (page [[acme]])))}}
```

4. Drop the renamed file into your graph's `pages/` folder, same as the other hubs.

Tag notes with the project name inline (`#acme`) or via a template's `tags::` field, no slash command needed.

**Why this matters:** when you tag a meeting with `tags:: meetings, acme`, it appears on both the `meetings` hub and the `acme` hub. The meeting hub shows all meetings across every project. The project hub shows every meeting, decision, incident, and brag for that one project. Two views, zero extra work.

**Sub-topics** come later. Once you have 3+ notes about a sub-area (e.g. onboarding, API design, compliance), create `acme/onboarding` as a namespace page. It will automatically appear under `## Sub-topics` via the namespace query. Do not pre create these, let them emerge.

If you have multiple projects, create one hub per project. They are independent.

### Companies hub (for vendors, customers, partners)

This is separate from your project hub. Your project (`acme`) is where you work. Companies are external entities you interact with, vendors, customers, agencies, partners.

```
# Page name: companies
icon:: 🤝
## All companies
{{query (namespace [[companies]])}}
```

Use namespaces for individual companies: `companies/stripe`, `companies/datadog`, `companies/agency-x`. Each company page collects every note, meeting, and decision involving them.

### Optional hubs (add if relevant)

The bundle also ships these two, ready to drop into `pages/` if they fit how you work:

- [`assets/pages/learning.md`](assets/pages/learning.md), 📚 learning, books, courses, notes to self
- [`assets/pages/career.md`](assets/pages/career.md), 💼 career, career growth, interviews

Skip them if you do not need them, nothing else depends on them.

## Step 4 — Add the `templates` page (2 min)

Same as the hubs: drop the file in, do not paste it. Pasting the templates into a block mangles the structure (Logseq's clipboard parser collapses the `## Section` headings into the wrong places).

1. Copy [`assets/templates.md`](assets/templates.md) into your graph's `pages/` folder.
2. Logseq loads it as the `templates` page, with all eight templates intact.

You should now have block templates for: `meeting`, `1on1`, `interview`, `brag`, `decision`, `book-note`, `incident`, `strikedoc`.

Test it: in any block, type `/template` and select `meeting`. Logseq injects the structured tree. Overwrite the placeholder headline on the first line with a real title.

## Step 5 — Try a real capture (3 min)

Go to today's journal page. In a new block, type:

```
/template brag
```

It expands to a headline placeholder with the brag properties attached to that same block:

```
- (the win, in one line)
  impact:: 
  evidence:: 
  tags:: brag
  what-i-did:: 
```

Overwrite the `(the win, in one line)` placeholder with your headline. That is what shows up on the hub. Then fill in the properties:

```
- set up a personal knowledge system so nothing important slips through the cracks
  impact:: recall any past decision, meeting or win in seconds
  evidence:: migrated my notes into Logseq, eight templates and the hub pages live, daily capture habit started Jun 12
  tags:: brag
  what-i-did:: built myself a second brain with structured templates and live query hubs so every meeting, decision and win is captured once and recalled instantly
```

Now open your `brag` hub page. You should see this entry there, headline and all, automatically.

That is the whole system. Everything else is just more of this.

## Step 6 — (Optional) Hide tag stubs from graph view (1 min)

As you tag content, Logseq auto creates "stub" pages for each tag (`meetings`, `brag`, etc.). To keep your graph view clean, add these properties to any pure tag page:

```
tags:: system
exclude-from-graph-view:: true
```

Apply this to tag stubs that have no content, only the hub queries. Skip this for hub pages and real content pages.

## Verification, you have done it right if:

- Typing `/attendees` in a block inserts `attendees:: `
- Typing `/template brag` inserts the full brag structure
- Your hub pages auto list content as you create it
- The graph view (☰ menu → Graph View) is not cluttered with empty stub pages

## Next: read [02-mental-model.md](02-mental-model.md) for the *why*

The setup works without understanding the model. But once you read about how content, tags, and properties fit together, the rest of the bundle makes sense and you can extend it without breaking it.
