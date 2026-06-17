# Mental model — the 3 tiers

Every page in your graph falls into one of three tiers. If you remember nothing else from this bundle, remember this:

## Tier 1: Hub pages

**What they are:** Aggregator pages with an icon and a live query.

**Examples:** `meetings`, `python`, `react`, `people`, `learning`, `acme` (your work)

**What they do:** Auto-list everything tagged with their name (or namespaced under them) via `{{query [[name]]}}`.

**Why they matter:** You never need to remember where you put something. You go to the hub for the topic, and there it is.

**Hub page template:**

```
icon:: 🎨

## Sub-topics (if you use namespaces)
{{query (and (namespace [[hub-name]]) (not (page [[hub-name]])))}}

## Tagged pages
{{query (and [[hub-name]] (not (page [[hub-name]])))}}
```

A hub is the dashboard for a topic. Click `meetings`, see every meeting you've ever noted. Click `python`, see every python-related page.

## Tier 2: Tag stubs

**What they are:** Empty pages used purely as tags.

**Examples:** `system`, `gold-mine`, individual property name pages like `attendees`, `status`

**What they do:** Nothing — they exist only because Logseq creates a page every time you reference `[[name]]` or write `tags:: name`. They have no content.

**Why they matter:** They make tags queryable and clickable. Their auto-creation is a Logseq quirk, not something you control.

**Tag stub template (apply to keep the graph view clean):**

```
tags:: system
exclude-from-graph-view:: true
```

You'll have dozens of these. They're invisible noise — hide them.

## Tier 3: Content pages

**What they are:** Real notes. The reason you opened Logseq.

**Examples:** A 1:1 with Bob. A book note on *Designing Data-Intensive Applications*. A decision log about which payment processor to use.

**What they do:** Hold your actual knowledge.

**Why they matter:** Everything else exists to make these findable and connectable.

**How they show up on hubs:** They include `tags:: <hub-name>` (or live in a namespace like `acme/audit`). The hub's query picks them up automatically.

---

## Why this model works

**Separation of concerns:**

- Hubs are *views*. They surface content but don't contain it.
- Stubs are *tags*. They categorize but don't carry information.
- Content pages are *data*. They hold what you actually wrote.

You can't accidentally lose a note by tagging it wrong, because **the same note can be tagged for multiple hubs**. A meeting with Bob that decided which payment processor to use? Tag it `meetings, decisions, people/Bob`. It shows on all three hubs.

**No central index needed:**

Wikis and docs systems often need a hand-curated index page. This model doesn't — queries are the index. They self-update as you add content.

**Namespaces add hierarchy when you need it:**

If you have lots of python pages (`python/celery`, `python/testing`, `python/packaging`), you can navigate them as a tree via Logseq's namespace UI. But you can also reach any of them via `{{query [[python]]}}`. Two access paths, zero extra work.

---

## What goes in which tier — decision tree

```
Are you writing something that will be referenced 2+ times?
├── Yes → Content page or block in journal
│   └── Tag it with relevant hub(s)
│
└── No (it's a category/label) → Tag stub
    └── Mark it system + exclude from graph view
```

```
Are you organizing a topic with 3+ related notes?
├── Yes → Create a hub page
│   └── Add icon + queries
│
└── No → Skip the hub. Just use the tag.
```

---

## The 3-level namespace rule

**Maximum 3 levels deep.** `acme/audit` is fine. `acme/audit/2026` is fine. `acme/audit/2026/q1` is too deep.

Why? Beyond 3 levels, navigation becomes worse than search. Names get long. Renames cascade. Mental load goes up.

If you're tempted to go 4 levels, flatten by combining: `acme/audit-2026-q1` (2 levels). Less elegant, but easier to maintain.

---

## What's *not* a hub

These look like hubs but aren't — they're just topic tags. The difference: hubs have content and queries; topic tags are passive markers.


| Not a hub                             | Why                                                  |
| ------------------------------------- | ---------------------------------------------------- |
| `gold-mine`                           | Just a quality marker — "this resource is excellent" |
| `system`                              | Logseq metadata — "this page is infrastructure"      |
| `reminder`                            | Just a flag for review later                         |
| `acme` (if you only have a few notes) | Becomes a hub only if you'd benefit from a dashboard |


The line between "topic tag" and "hub" is fuzzy. Rule of thumb: **make a hub only when you have 3+ notes you'd want to see together.**

---

## Powertags — the note types that sit on top of the tiers

The 3 tiers above describe *pages*. **Powertags** describe the *note types* that flow through them.

A powertag is a note type that ships pre-built with two things:

- a **template** that inserts the field structure *and* the tag in one go — `/template meeting`
- a **hub** that auto-collects every one you write — `[[meetings]]`

The bundle includes 8: `meeting`, `1on1`, `interview`, `brag`, `book-note`, `incident`, `decision`, `strikedoc`. They're the things you create over and over — events and artifacts.

There's nothing new here: a powertag note is just a **Tier 3 content block** carrying `tags:: <name>`, which lands it on that name's **Tier 1 hub**. "Powertag" is simply the three tiers working together, packaged under one name so you never rebuild the structure by hand.

**People and companies are not powertags.** They're *entities* — stable things your notes point at. You don't write a note "of type person"; you create a `people/bob` page once and reference it (`attendees:: [[people/bob]]`). Entities get hubs (via namespace and backlinks) but no template and no `tags::` of their own.

## Next: read [03-powertags.md](03-powertags.md) for the note types

Powertags are *for things you make many of* (meetings, brags, decisions, etc.). The bundle ships with 8, each with a template and a hub. The next file walks through them with examples.