# Virtual Cortex

**Agent-driven personal knowledge management for Logseq.** Your AI captures your meetings, surfaces the wins you forgot to log, preps your 1:1s, and answers questions over your whole graph with local semantic search — all stored as plain-text Logseq you fully own. No plugins, no subscription, no lock-in.

> Built and refined across 2,000+ pages of real work notes, three projects, and a daily-driver training journal. Not a weekend experiment — a system that survived daily use at scale.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## The headline: AI agent skills

Most "Logseq setups" are dotfiles — themes, shortcuts, plugins. Virtual Cortex ships something newer: **AI agents that do the capture and recall for you.** They run in [Claude Code](https://claude.ai/code), Cursor, or any Claude-compatible agent, and read/write your graph through [mcp-logseq](https://github.com/ergut/mcp-logseq).

| Skill | What it does for you |
|-------|----------------------|
| **`meeting-sync`** | Pulls a meeting from your transcript tool (Granola, Otter, Fireflies…) into today's journal — structured, tagged, attendees auto-linked to their pages. |
| **`meeting-prep`** | Before a meeting with someone, surfaces your last 3 meetings with them and every open action item in both directions. You look prepared without trying. |
| **`brag-finder`** | Scans your journal for wins you forgot to log, and offers to file them as `#brag`. Performance-review prep on autopilot. |
| **`weekly-review`** | Reads the last 7 days and assembles your brags, decisions, meetings, incidents, and open/closed TODOs into one review block. |
| **`logseq-note`** | Saves a decision or insight from an AI coding session straight into the right hub. |
| **`graph-init`** | Scans your *existing* graph, discovers the tags you already use, and maps them onto the system so you don't start from zero. |
| **`virtual-cortex-setup`** | One guided command that verifies the connection, scans your graph, and creates every hub, template, and slash command for you. |

The skills compose into a daily loop: `meeting-sync` captures → `meeting-prep` recalls → `brag-finder` + `logseq-note` file the wins → `weekly-review` rolls it up. **The system gets denser the more you use it.**

→ Full skill setup and MCP config (Claude Code / Cursor / Claude Desktop) in **[skills/README.md](skills/README.md)**.

---

## Local semantic search

Beyond tags and queries, Virtual Cortex can run **semantic search over your entire graph using local AI embeddings** — ask in plain language and get the right notes back, even when you don't remember the tag. Everything runs on your machine via [Ollama](https://ollama.com) + [LanceDB](https://lancedb.com); no data leaves your computer.

→ Setup (Mac, tested) in **[07-vector-db-setup.md](07-vector-db-setup.md)**.

---

## Underneath: a structure that doesn't rot

The agents work because the graph beneath them is opinionated and consistent. That structure is the other half of the bundle, and it stands on its own if you never touch the AI:

- **A 3-tier mental model** — hubs, tag stubs, content pages. Clear rules for what goes where, so you never wonder where you put something.
- **"Powertags" without a plugin** — `#meeting`, `#brag`, `#decision`, `#incident` and more, each a one-keystroke template that auto-aggregates onto its hub.
- **Namespace hierarchies** — `python/celery`, `acme/audit` — max 3 levels, enforced by convention.
- **Hub pages** with live queries that gather everything tagged or namespaced under them. Stop building manual index pages.
- **Uplifts PARA, doesn't replace it.** Projects become hubs, Resources become namespaces, Archives become a `status::` flip. PARA is the taxonomy; this is the engine.

---

## Who this is for

- **Engineering managers and senior devs** who need 1:1 notes, decision logs, brag docs, and incident records — all linkable, queryable, and version-controlled. (There's even a private `strikedoc` type that AI agents are configured to never read.)
- **Logseq users** drowning in unstructured pages and stub tags.
- **PKM refugees** who want structure without a subscription or vendor lock-in.
- Anyone who tried building this themselves and gave up after three hours of plugin spelunking.

New to Logseq? [Install it first](https://logseq.com) — this assumes you have a graph and know the basics (pages, blocks, `[[links]]`, `tags::`).

---

## Quick start

**AI-assisted (recommended, ~10 min):** install [uv](https://docs.astral.sh/uv/#installation), enable Logseq's HTTP API and create a token, add [mcp-logseq](https://github.com/ergut/mcp-logseq) to your agent, copy the skills (`cp -r skills/* ~/.claude/skills/`), then run `/virtual-cortex-setup`. Full walkthrough: **[01a-setup-ai.md](01a-setup-ai.md)**.

**Manual (~15 min, no AI):** drop `assets/templates.md` and the hub files from `assets/pages/` into your graph's `pages/`, paste the `:commands` block from `assets/config.edn` into `logseq/config.edn`, restart, and run `/template meeting`. Full walkthrough: **[01b-setup-manual.md](01b-setup-manual.md)**.

Not sure which? Start with **[01-setup.md](01-setup.md)**.

---

## What's inside

| File | Purpose |
|------|---------|
| [01-setup.md](01-setup.md) | Setup overview — pick your path |
| [01a-setup-ai.md](01a-setup-ai.md) | AI-assisted setup |
| [01b-setup-manual.md](01b-setup-manual.md) | Manual setup, no AI |
| [02-mental-model.md](02-mental-model.md) | The 3-tier model and why it works |
| [03-powertags.md](03-powertags.md) | All 8 note types with worked examples |
| [04-daily-flow.md](04-daily-flow.md) | The daily rhythm in motion |
| [05-extend.md](05-extend.md) | Adding your own powertags and hubs |
| [06-faq.md](06-faq.md) | Common questions, plugin recommendations |
| [07-vector-db-setup.md](07-vector-db-setup.md) | Local semantic search (Ollama + LanceDB) |
| `assets/` | `config.edn`, `templates.md`, and ready-to-drop hub pages |
| `scripts/` | Helper scripts (e.g. `sync-assets.sh`) |
| `skills/` | The AI agent skills |

---

## Contributing

Issues and PRs welcome — especially new skills. A few that are deliberately *not* in the box (build them and send them back for v2): `daily-summary`, `linear-to-logseq`, `pr-to-brag`. See the notes at the bottom of [skills/README.md](skills/README.md).

---

## License

[MIT](LICENSE). Use it, fork it, sell your own variants — no attribution required, though a star or a link back is always appreciated.

---

Built by [Mayank Sehgal](https://www.linkedin.com/in/mayank-sehgal-9b320a92/). I write about software engineering craft at [Agnostic Logic](https://agnosticlogic.substack.com). If Virtual Cortex saved you an afternoon and you'd like help wiring it into your own workflow, [reach out](mailto:sehgalmayank001@gmail.com).
