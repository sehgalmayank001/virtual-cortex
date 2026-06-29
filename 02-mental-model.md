# Mental model — content, tags, and properties

If you remember nothing else from this bundle, remember this: **you write content, you group it with tags, and you slice it with properties.** Everything else — hubs, queries, namespaces — is convenience built on those three things.

There are no special kinds of page to learn. In Logseq, everything you reference is a page; the system is just a *schema* — a few naming and tagging conventions — laid over that flat space.

## The three moving parts

### 1. Content — what you actually write

A meeting note. A decision log. A book note. A page about `python/celery`. These hold your knowledge; everything else exists to make them findable.

Most content lives as **blocks in the daily journal** (low friction, captured as it happens). Some lives on its **own page** when it's a reusable doc you'll link to from many places. Both are just content.

### 2. Tags — grouping

A tag answers *"what bucket is this in?"* You tag a meeting note with `meetings`; you tag a work note with `acme`.

The mechanics matter and they're simpler than they look:

- Referencing a name — `[[meetings]]`, `#meetings`, or `tags:: meetings` — makes Logseq create a page for that name if it doesn't exist.
- That page's **Linked References** section then lists **every block that references it, automatically**. No query required.

So a tag buys you grouping for free: tag 30 things with `meetings`, open the `meetings` page, and Logseq already shows all 30 under Linked References. **Backlinks are the index.** You never hand-maintain a list.

A note can carry as many tags as you like — `tags:: meetings, decisions, acme` puts one block in three buckets at once. Nothing is lost by tagging it "wrong"; tag it for every bucket it belongs to.

### 3. Properties — slicing

This is the real engine, and the part most note systems miss.

A tag only gives you the whole bucket: *all* meetings. A **property** lets you carve that bucket into the views you actually want:

- `type:: 1on1` → "just my 1:1s," not every meeting
- `type:: interview` → "just interviews"
- `status:: open` → "incidents still on fire," not the resolved ones
- `status:: reading` → "books I'm in the middle of"
- `attendees:: [[people/John]]` → "meetings with John"

Tags can't do this on their own. "All my 1:1s with John" is a *tag* (`meetings`) sliced by *two properties* (`type:: 1on1` and `attendees:: [[people/John]]`). Backlinks alone would also surface a group meeting John merely attended — the property is what makes the view precise.

**Properties are the spine of the system.** Tags get you to the bucket; properties get you to the answer.

That's the entire data model — content, grouped by tags, sliced by properties. Everything from here on is just convenience built on top of it.

## Which queries are worth saving

A plain tag page already aggregates everything tagged with it through Linked References, so an "all X" query just re-renders what Logseq shows for free. Don't bother saving those. Only two kinds of query add something backlinks can't:

- **Property facets** — slice a tag by a property. `(property type "1on1")` gives you *just 1:1s*; `(property status open)` gives you *just the open incidents*. This is the payoff of properties — Linked References can't filter by `type::` or `status::`. The facet only works if your content carries the property (see the write convention below): a meeting with no `type::` shows in backlinks but never under *1:1s*.
- **Namespace lists** — `(namespace [[people]])` lists the child pages under a namespace, which is a different thing from backlinks.

A tag page you've curated this way — an icon, plus whichever facet or namespace queries are worth keeping — is what the rest of this bundle calls a **hub**. That's all "hub" means: a tag page with saved views on it, not a separate kind of object. Add a query only for a facet, a namespace list, a synonym merge (`(or [[brag]] [[shipped]])`), or a curated description — never for plain aggregation.

```
icon:: 📅
- ## 1:1s
	- {{query (and [[meetings]] (property type "1on1"))}}
- ## Interviews
	- {{query (and [[meetings]] (property type interview))}}
```

> Quoting quirk: a property value that starts with a digit must be quoted in the query — `(property type "1on1")`, not `(property type 1on1)`, which Logseq fails to parse. Alphabetic values like `interview` don't need quotes. Each faceted hub lists its allowed values in a `*-values::` page property so they're discoverable.

## The canonical write convention

There is **one** way notes get written so they tag and slice correctly. The `/template` command does it for you in the app; the AI skills do the same through the API.

- **Tags go on a `tags::` line directly under the title bullet** (un-dashed), so they attach to that block:
  ```
  - Squad standup
    type:: 1on1
    attendees:: [[people/bob]]
    tags:: meetings, acme
    - ## Notes
      - ...
  ```
- **Scalar property values are bare** — `type:: 1on1`, `status:: open`. Never bracket them.
- **Reference properties hold page links** — `attendees:: [[people/bob]]`, `company:: [[acme]]`.
- **Don't put `tags::`/`type::` on a dashed child bullet** (`- tags:: …`). The dash makes it a separate block and the title stays untagged.
- **If a freshly written note doesn't show on its hub, re-index once** (Logseq graph menu → Re-index). File and API writes can lag Logseq's live index; a re-index resolves them. You only need this after a bulk write.

That's the whole convention. Manual capture and AI capture produce the same block shape, so everything queries the same way.

## Namespaces — hierarchy when you want it

Namespaces (`python/celery`, `acme/audit`) give you a tree without extra work. `python/celery` is reachable through Logseq's namespace UI *and* via `{{query [[python]]}}` — two access paths, zero duplication.

**Maximum 3 levels deep.** `acme/audit` is fine; `acme/audit/2026` is fine; `acme/audit/2026/q1` is too deep. Past 3 levels, names get long, renames cascade, and search beats navigation. If you're tempted to go deeper, flatten by combining: `acme/audit-2026-q1`.

## Decide: tag or property?

```
Writing something you'll want to find again?
└── Yes → content (journal block, or its own page if it's a reusable doc)
          └── add tags:: for every bucket it belongs to

Want to see a *slice* of a tag (just 1:1s, just open incidents)?
└── Yes → that distinction is a property (type::, status::), not a new tag

Reaching for the same view over and over?
└── Save it as a query on the tag page (that's all a "hub" is).
    Otherwise don't — Linked References already aggregate the tag.
```

Rule of thumb: **everything is a tag or a property.** Saving a query on a tag page is optional, and only worth it when the query does something backlinks can't — a property facet, a synonym merge, or a curated landing page.

## People and companies are entities, not note types

You don't write a note "of type person." You create `people/bob` once and *reference* it (`attendees:: [[people/bob]]`). The person page then aggregates everything about them through backlinks — every meeting, every 1:1 — with no "Bob series" page to maintain. Link people to where they belong with a `company::` property (`company:: [[acme]]` or `company:: [[companies/stripe]]`) so the connection is queryable from both sides.

Companies work the same way under the `companies/` namespace for external vendors, customers, and partners.

## Why this holds up

- **Nothing to file.** You capture once and tag; queries and backlinks handle visibility. No moving notes between folders.
- **No central index to maintain.** Backlinks are the index; they self-update.
- **Precise recall.** Properties let you ask exact questions ("open sev1 incidents this quarter") instead of scrolling a bucket.
- **It bends to you.** Don't like a hub? Delete it — the tag still works. Don't need a facet? Drop the property.

The only invariants worth protecting: max 3 namespace levels, lowercase-hyphenated names, the canonical write convention above, and faceted hubs listing their allowed property values.

## Next: read [03-powertags.md](03-powertags.md) for the note types

The bundle ships 8 ready-made note types (meetings, brags, decisions, incidents…), each a template that stamps the right tags and properties in one keystroke. The next file walks through them with examples.
