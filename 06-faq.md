# FAQ

## Do I need any plugins?

**No.** Every pattern in this system uses native Logseq features. Plugins are optional accelerators.

That said, these plugins are nice-to-haves (none required):

| Plugin | What it does | Worth it? |
|--------|--------------|-----------|
| Tabs | Multi-document tabs | Yes — quality of life |
| Bullet Threading | Visual indent guide lines | Yes — helps deep outlines |
| Tags | Alphabetical tag listing | Yes — complements the system |

We **don't** recommend:

| Plugin | Why skip |
|--------|----------|
| logseq-powertags-plugin | Its only feature (auto-inject properties on `#tag`) duplicates what `/template` does, with the downside of hidden plugin storage |
| Logseq Graph Analysis | Looks cool, rarely useful in daily work |
| Any "task management" plugin | Logseq's built-in TODO/DOING/DONE plus the NOW/NEXT queries are enough |

## How does this relate to PARA or Building a Second Brain?

**It uplifts PARA, it doesn't replace it.** PARA is a taxonomy — it tells you *where* a note belongs (Projects, Areas, Resources, Archives). This system is the engine that makes those buckets queryable and low-friction:

- **Projects** → project/company hubs (`acme/`)
- **Areas** → standing hubs (`meetings`, `decisions`, `career`)
- **Resources** → namespaced topic pages (`python/celery`) and `books`
- **Archives** → a `status::` flip (`resolved`, `read`), not a move

The real difference is mechanics: PARA asks you to *file and move* notes between buckets; here you capture once in the journal, tag it, and let live queries handle visibility. You keep PARA's vocabulary but drop the manual upkeep that makes most PARA setups rot. Short version: **PARA is the taxonomy, this is the engine.**

## Why no parent namespace like `jobs/` for companies?

Companies/projects are *hubs in their own right* — not nested under a parent category. You'd want a dashboard for "everything at company X", and that's exactly what a top-level hub gives you.

If you have multiple jobs/projects, make each a top-level: `acme/`, `widget-co/`, etc. Don't put them under a shared `jobs/` parent unless you genuinely think in those terms.

## What if I switch jobs?

The structure handles it cleanly:

- Old job stays as a hub with its existing children (`acme/audit`, `acme/q2-planning`, etc.)
- New job becomes another top-level hub (`widget-co/`)
- Cross-cutting tags (`brag`, `decisions`, `incidents`) keep working — they're not job-specific

No reorganisation needed. The model is job-agnostic.

## What if my graph gets huge?

This system was built on a graph with 2,000+ pages across 3 projects. It scales.

What to watch for:

- Hub queries get slower past ~5,000 references — add date filters: `{{query (and [[meetings]] (between -90d today))}}`
- Graph view becomes unusable past ~2,000 visible pages — use `exclude-from-graph-view` aggressively
- High-volume hubs can be split into year buckets: `meetings/2026`

## What if I hate one of the powertags?

Delete it. From `[[templates]]` and from your hub list. The core invariants (the content + tags + properties model, 3 namespace levels, lowercase-hyphenated names, and the canonical write convention) are what matter — the specific powertag list is yours to curate.

## Can AI agent writes collide with my simultaneous edits?

**Rarely, but possible.** The AI agent writes to your graph through the HTTP API while you might be editing the same journal page in the Logseq app. Both write to the same markdown file. If you save a block at the exact moment the agent appends one, you could get a merge conflict or duplicate content.

In practice this is unlikely — the agent's writes are fast append operations to the end of today's journal, and you're usually editing older blocks or a different line. To be safe, avoid heavy manual editing of today's journal while running a skill that writes to it (`meeting-sync`, `weekly-review`, `brag-finder`). Let the skill finish, then do your own edits.

## How do I back up my graph?

Your graph is plain markdown files — backup is straightforward:

- **Git.** Initialize a repo in your graph folder (or add it to an existing one) and commit periodically. Logseq graph folders live in iCloud Drive at `~/Library/Mobile Documents/iCloud~com~logseq~logseq/Documents/<graph-name>/`.
- **rsync / Time Machine.** Your iCloud Drive is backed up by Time Machine if you have it enabled. For extra safety, `rsync` the graph folder to another drive.
- **Version history.** iCloud Drive keeps 30-day version history on macOS. Right-click any file → Browse All Versions.

What matters most: the `journals/` and `pages/` folders. The rest (`.DS_Store`, `assets/`, `logseq/`) can be regenerated or is cache.

## Does `LOGSEQ_EXCLUDE_TAGS` hide the page completely?

**Yes.** Any page carrying a tag listed in `LOGSEQ_EXCLUDE_TAGS` (default: `private`) is fully invisible to the AI — it won't appear in listings, searches, or queries. This is by design: strikedocs and sensitive pages should never surface.

The trade-off: if you tag a page `tags:: private, decisions, brag` (trying to track a performance issue about a past win), the entire page disappears. No partial visibility. If that's a problem, split the content: keep sensitive observations on a `tags:: private` page and file the decision/brag separately without `private`.

## Where's the support if I get stuck?

1. Re-read [01-setup.md](01-setup.md) and [02-mental-model.md](02-mental-model.md) — most issues are setup typos or model misunderstanding
2. Check Logseq's official docs at [docs.logseq.com](https://docs.logseq.com)
3. Ask in the Logseq Discord — community is friendly and active
