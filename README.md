# Virtual Cortex

A complete, opinionated structure for using Logseq as a serious personal knowledge management tool — without plugins, without subscriptions, without spending weekends fighting your notes app.

---

## What this is

A bundle of patterns, templates, and configurations that turns Logseq into a structured knowledge system. It covers:

- **A 3-tier mental model** — hubs, tag stubs, and content pages. Clear rules for what goes where.
- **"Powertags" without a plugin** — structured tag types like `#meeting`, `#brag`, `#decision` that auto-inject the right fields using Logseq's native templates.
- **Namespace hierarchies** — `python/celery`, `react/hooks`, `acme/audit`. Max 3 levels deep, enforced by convention.
- **Hub pages** with live queries that auto-aggregate everything tagged or namespaced under them.
- **Template-driven capture** plus property-shortcut slash commands for daily journal use.
- **Seven ready-to-run AI agent skills** (Claude Code, Cursor compatible) for guided setup, automated capture, weekly reviews, meeting prep, and forgotten-brag recovery.

You'll be capturing meeting notes, decisions, and book notes in seconds, and finding anything from 6 months ago without thinking about where you put it.

---

## Who this is for

- **Logseq users** drowning in unstructured pages and stub tags
- **Users of other PKM tools** who want structured notes without a subscription or vendor lock-in
- **Engineering managers / senior devs** who need 1:1 notes, decision logs, brag docs, incident records — all linkable, queryable, and version-controlled
- Anyone who's tried building this themselves and given up after 3 hours of plugin spelunking

If you don't already use Logseq, [install it first](https://logseq.com). This bundle assumes you have a graph and you've used the basics (pages, bullet blocks, `[[links]]`, `tags::`).

---

## What's inside this bundle

| File | Purpose |
|------|---------|
| [01-setup.md](01-setup.md) | Start here, choose your setup path |
| [01a-setup-ai.md](01a-setup-ai.md) | AI-driven setup (~10 min, uses an AI agent + mcp-logseq) |
| [01b-setup-manual.md](01b-setup-manual.md) | Manual setup (~15 min, no AI, just file drops) |
| [02-mental-model.md](02-mental-model.md) | The 3-tier model and why it works |
| [03-powertags.md](03-powertags.md) | All 8 powertags with worked examples |
| [04-daily-flow.md](04-daily-flow.md) | Real-world examples and the daily rhythm |
| [05-extend.md](05-extend.md) | Adding your own powertags and hubs |
| [06-faq.md](06-faq.md) | Common questions, including plugin recommendations |
| `assets/config.edn` | Property-shortcut slash commands |
| `assets/templates.md` | Templates page (paste into your graph) |
| `skills/` | Seven AI agent skills — setup, graph init, capture, review, meeting prep, brag finder |

---

## Quick-start

Two paths to the same end state. Pick one.

### Path A — AI-driven setup (recommended, ~10 min)

You need an AI agent (Claude Code, Cursor, or Claude Desktop), [uv](https://docs.astral.sh/uv/#installation), and the [mcp-logseq](https://github.com/ergut/mcp-logseq) server.

1. **Enable Logseq's HTTP API:** Settings → Features → "Enable HTTP APIs server" → click the plug icon → "Start server" → create an API token.
2. **Add mcp-logseq to your agent.** See [skills/README.md](skills/README.md) for copy-paste configs.
3. **Copy the skills** to your agent's skill directory (`cp -r skills/* ~/.claude/skills/` or equivalent).
4. **Run `/virtual-cortex-setup`.** It verifies the connection, scans your graph, creates hub pages and templates, and tells you which slash commands to paste.

Full walkthrough: [01a-setup-ai.md](01a-setup-ai.md).

### Path B — Manual setup (~15 min)

No AI, no MCP, no terminal. You drop ready-made files into your graph.

1. **Drop the hub files** from `assets/pages/` (`meetings.md`, `brag.md`, `decisions.md`, `books.md`, `incidents.md`, …) into your graph's `pages/` folder. Each already carries its icon and a self-excluding query. Drop them in, do not paste them into a block.
2. **Drop `assets/templates.md`** into the same `pages/` folder, it becomes the `templates` page with all eight templates intact.
3. **Paste the `:commands` block** from `assets/config.edn` into `logseq/config.edn`, then restart Logseq.
4. **Try it.** In today's journal, run `/template meeting`, then fill in `attendees::` and your notes.

Full walkthrough: [01b-setup-manual.md](01b-setup-manual.md).

Path A also scans your existing tags and merges them into the hub queries. Not sure which to pick? See [01-setup.md](01-setup.md).

---

## What makes this different

Most "Logseq setups" you find online are dotfile collections — themes, shortcuts, plugins. This bundle is **opinions backed by patterns**:

- **Uplifts PARA, doesn't replace it.** Keep PARA's mental buckets — Projects become hubs, Areas become standing hubs, Resources become namespaces, Archives become a `status::` flip instead of a move. PARA is the taxonomy; this is the engine. It swaps manual filing and folder-shuffling for capture-first journaling, tags, and live queries — exactly where PARA tends to break down in practice.
- **No required plugins.** Everything works with native Logseq features. Plugins are optional accelerators, not foundations.
- **Visible source of truth.** Every powertag, template, and rule lives in a Logseq page or `config.edn` — never in plugin internals you can't read.
- **Tested by usage.** Built and refined across 2,000+ pages of real work notes, 3 projects, and a personal training journal. This isn't a weekend experiment — it's a system that survived daily use at scale.
- **Designed to scale or shrink.** Use 2 powertags or all 8. Skip the namespaces if you hate hierarchy. The pieces work independently.

---

## Credits / inspiration

The Logseq-specific implementation borrows from the community at [logseq.com](https://logseq.com).

Built for someone who switched projects, switched note apps, and decided to stop reinventing the wheel.

---

## License

Use it. Adapt it. Share it. Sell your own variants if you want — just don't pretend you wrote the whole thing.
