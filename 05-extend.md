# Extend — your own powertags and hubs

The 8 bundled powertags cover most knowledge work. But you'll have your own use cases. Here's how to add them cleanly.

---

## The rule: 3-strike before structure

**Don't add a powertag preemptively.** Capture the same kind of thing manually 3+ times first. Then you'll know:

1. The fields you actually use (not the ones that sounded good in theory)
2. Whether it deserves its own type vs. just being tagged
3. What the hub query should filter

If you create a powertag and use it once, it's noise. If you create it after 3 manual examples, it pays for itself.

---

## Adding a powertag — full walkthrough

Let's say you keep doing **architecture reviews** at work. Each one has: a doc link, an author, a date, your verdict, and trade-offs. You've taken notes on 3 of them in unstructured blocks. Time to make it a powertag.

### Step 1 — Add a template (2 min)

Open `[[templates]]` page. Add a new block at the bottom:

```
## Architecture review
- template:: arch-review
  - doc:: 
  - author:: 
  - verdict:: 
  - tags:: arch-reviews
  - ## Strengths
    - 
  - ## Concerns
    - 
  - ## Trade-offs
    - 
```

Now `/template arch-review` injects this structure.

### Step 2 — Create a hub (2 min)

Create a new page called `arch-reviews`:

```
icon:: 🏗️

## All reviews
{{query (and [[arch-reviews]] (not (page [[arch-reviews]])))}}

## By verdict
### Approved
{{query (and [[arch-reviews]] (property verdict approve))}}

### Rejected
{{query (and [[arch-reviews]] (property verdict reject))}}
```

### Step 3 — Test (30 sec)

Go to today's journal. Type the review title, indent, then `/template arch-review`. Fill in. Verify it shows on the `arch-reviews` hub.

Done. Total time: ~4 minutes.

---

## When to use a namespace vs. a flat tag

You'll hit this question: should it be `arch-reviews` (flat) or `acme/arch-reviews` (namespaced)?

| Use flat | Use namespace |
|----------|---------------|
| The concept is universal (applies across companies, topics) | The concept is specific to a parent (only applies to one company/project) |
| You might use it across multiple jobs/contexts | It will never exist outside this parent |
| You want it as a top-level hub | It's a subcategory of an existing hub |

Examples:

- `decisions` → flat (decisions are universal)
- `acme/dha` → namespaced (DHA is a regulation specific to acme)
- `python/celery` → namespaced (it's a python sub-topic)
- `meetings` → flat (you have meetings everywhere)

**Default to flat.** Namespace only when the relationship is structural and durable.

---

## When to make a hub vs. just a tag stub

| Make a hub | Make a tag stub |
|-----------|------------------|
| You'll have 3+ entries to surface together | One-off categorization marker |
| You'd benefit from a queried dashboard | The tag is just for findability |
| Future-you wants a place to "open the topic" | The tag is metadata noise |

A hub has:
- An icon
- Live queries
- Maybe a description block

A stub has:
- `tags:: system`
- `exclude-from-graph-view:: true`
- Nothing else

If you're not sure, start as a stub. Promote to hub once you have 3+ entries.

---

## Already have tags? Bring them

If your graph already has tags like `#standup`, `#retro`, `#postmortem`, `#shipped` — you don't need to throw them away. Here's how to bridge.

### Option 1 — Merge queries (recommended)

Keep your existing tags. Make hub queries include both old and new:

```
## All meetings
{{query (or [[meetings]] [[standup]] [[retro]] [[1:1]])}}
```

New content uses `/template meeting` and the bundle's conventions. Old content stays findable through the merged query. No migration, no breakage.

### Option 2 — Rename to match the bundle

Logseq updates backlinks automatically when you rename a page. Rename `standup` → redirect users to tag `meetings` with `type:: standup`. Cleaner long-term, but one-way.

### Option 3 — Adapt the bundle to your names

If you already have 50 entries tagged `#shipped` and zero tagged `#brag`, rename the bundle's brag hub to `shipped`. Change the template's `tags::` field and the hub query. The system doesn't care what words you use — it cares about the pattern (hub + template + query).

### The transition period

For the first 2-4 weeks, you'll have some notes using old conventions and some using new. This is fine. The merged queries (Option 1) handle it. Don't try to backfill old entries — just tag forward.

If you have the AI agent skills installed, run `/graph-init` to automate the scan and setup. It will find your existing tags, suggest mappings, and scaffold hubs that query both old and new tag names.

---

## Anti-patterns to avoid

### 1. Pre-structuring everything

> "Let me create powertags for #goal, #project, #idea, #weekly-review, #book, #podcast, #YouTube-talk..."

You'll use 2 of those and abandon the rest. Build from observed usage, not from a vision board.

### 2. Renaming powertags every week

A powertag's value comes from accumulated history. Renaming `brag` → `wins` → `accomplishments` → `achievements` over 6 months means none of them have enough data to matter. Pick a name, commit.

### 3. Tagging every block

You don't need to tag random thoughts in your journal. Tag the ones you'd want to find again. Untagged blocks are still findable via search and date — they just don't show on hubs.

### 4. Building deeper than 3 levels

`acme/dha/audit/2026/q1` is a folder, not a tag. You'll never type that. Flatten: `acme/dha-q1-2026-audit`. Or, better: a single page tagged with `acme/dha`.

### 5. Hub queries that return 500+ blocks

Performance degrades. Either filter (add a date range, property filter, or status) or split into sub-hubs.

---

## What to do when something feels wrong

The system is a starting point, not a contract. If a piece doesn't fit your workflow:

- A template you don't use → delete it from `[[templates]]`
- A hub that's always empty → delete it
- A slash command that never fires → remove from `config.edn`
- A namespace that feels forced → flatten it (rename pages, the convention is yours)

Just don't break the invariants:
- Max 3 levels deep
- Lowercase + hyphenated namespace names
- Hub queries use `{{query [[name]]}}`
- Tag stubs get `tags:: system` and `exclude-from-graph-view:: true`

Those four rules are what makes the system durable.

---

## Next: [06-faq.md](06-faq.md) — questions you'll have

Common questions about plugins, performance, syncing, and edge cases.
