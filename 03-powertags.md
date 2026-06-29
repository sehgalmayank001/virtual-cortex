# Powertags — the 8 note types

A **powertag** is a note type that comes pre-built. Instead of remembering how to structure a meeting note or a decision log, you invoke the powertag and get the whole skeleton — already carrying the right tags and properties.

It's the three moving parts from [02-mental-model.md](02-mental-model.md) packaged under one name:

- **Structure** — a template (`/template meeting`) inserts the full field tree, with the **tag** baked in (`tags:: meetings`, for grouping) and the **facet properties** in place (`type::`, `status::`, for slicing)
- **Collect** — a saved view (the `[[meetings]]` hub) surfaces every note carrying that tag, and slices it by property into facets like *1:1s* and *Interviews*

That's the whole idea: **template + saved view, one keystroke away.** The template carries the tag and properties, so you never insert them separately — and because the skills write the same shape through the API, AI capture lands in the same facets as manual capture.

**Properties are what make the facets work.** Tagging a note `meetings` gets it into *All meetings*; only `type:: 1on1` gets it into the *1:1s* facet. If a note skips the property, it still shows in the bucket but not the slice. Keep facet values bare (`type:: 1on1`); each hub lists its allowed values.

**Powertags are note types, not entities.** People and companies aren't powertags — you *reference* them (`attendees:: [[people/bob]]`), you don't stamp a note as "a person". They aggregate via namespace and backlinks instead. See [02-mental-model.md](02-mental-model.md) for that distinction.

---

## The 8 powertags

| Powertag | Hub | Use when |
|----------|-----|----------|
| `meeting` | [[meetings]] | Any meeting note |
| `1on1` | [[meetings]] | 1:1 notes (link the person via `attendees::`) |
| `interview` | [[meetings]] | Candidate interview (link the person via `candidate::`) |
| `brag` | [[brag]] | A personal win, accomplishment, recovered fire |
| `book-note` | [[books]] | Reading note |
| `incident` | [[incidents]] | Production issue |
| `decision` | [[decisions]] | A tech/product decision worth remembering |
| `strikedoc` | none (private) | Performance documentation for a person or team |

---

## 1. `meeting` — generic meeting note

**When:** Anything with attendees that you took notes on.

**Template** (`/template meeting`):
```
- 
  type:: 
  attendees:: 
  tags:: meetings
  - ## Agenda
    - 
  - ## Notes
    - 
  - ## Action items
    - TODO 
  - ## Decisions
    - 
```

**Filled example:**
```
- [[meetings]] Squad 1 Stand Up
  type:: standup
  attendees:: [[people/juan]], [[people/Bob]], [[people/daniil]]
  tags:: meetings, acme
  - ## Notes
    - Daniil deployed moderation PR — live in 30 min
    - UTM tracking gap: params not surviving sign-up redirect (Squad 2 changes)
  - ## Action items
    - TODO Retest UTM tracking end-to-end (Mayank + Daniil)
    - Deploy moderation to public channels (Daniil)
```

**Note the TODO discipline:** only items you own become `TODO`. Other people's items stay as plain bullets so they don't pollute your TODO views.

## 2. `1on1` — specialized meeting

**When:** Recurring 1:1 with a single person.

**Quick capture:** type the person's name as the block, then indent and run `/template 1on1` for the full 1:1 structure.

**Template** (`/template 1on1`):
```
- 
  type:: 1on1
  attendees:: 
  tags:: meetings
  - ## Their updates
    - 
  - ## My updates
    - 
  - ## Feedback (both ways)
    - 
  - ## Action items
    - TODO 
```

**No "series" page needed.** Each 1:1 lives in that day's journal. Opening the person's page (`people/Bob`) automatically lists every 1:1 you've had with them — that's the [entity-aggregator pattern](#entity-aggregation-explained).

## 3. `interview` — candidate evaluation

**When:** Interviewing a job candidate.

**Quick capture:** type the candidate's name as the block, then indent and run `/template interview` for the interview structure.

**Template** (`/template interview`):
```
- 
  type:: interview
  candidate:: 
  role:: 
  tags:: meetings
  - ## Background
    - 
  - ## Technical
    - 
  - ## Questions they asked
    - 
  - ## Verdict
    - 
```

## 4. `brag` — your wins

**When:** You shipped something. You fixed a fire. You influenced a decision. You leveled someone up.

**Template** (`/template brag`):
```
- 
  impact:: 
  evidence:: 
  tags:: brag
  what-i-did:: 
```

**Why this matters:** Performance reviews ask you what you did. By the time you're reminded to remember, you've forgotten 80%. A brag log is the highest-ROI 30-second habit in tech.

**Filled example:**
```
- 
  impact:: reduced p99 checkout latency from 4.2s to 0.8s
  evidence:: PR #4521, dashboard linked, customer success thanked us on Slack
  tags:: brag, acme
  what-i-did:: traced down a missing index on subscription_events; added it with zero downtime; documented in python/performance
```

## 5. `book-note` — what you got from a book

**When:** Halfway through a book and want to remember a key idea. After finishing a book and want to compress it.

**Template** (`/template book-note`):
```
- 
  author:: 
  status:: reading
  tags:: books
  - ## Key ideas
    - 
  - ## Quotes
    - 
  - ## Actions
    - TODO 
```

`status::` values: `to-read`, `reading`, `read`. The hub page can split by status.

## 6. `incident` — production fire

**When:** Something broke in prod. Even minor.

**Template** (`/template incident`):
```
- 
  severity:: 
  status:: open
  tags:: incidents
  - ## Timeline
    - 
  - ## Root cause
    - 
  - ## Fix
    - 
  - ## Followups
    - TODO 
```

`severity::` values: `sev1` (page-out), `sev2` (degraded), `sev3` (cosmetic). `status::` values: `open`, `mitigated`, `resolved`.

## 7. `decision` — tech/product call

**When:** You picked one option over others, and your future self will want to know *why*.

**Template** (`/template decision`):
```
- 
  status:: decided
  context:: 
  options:: 
  chosen:: 
  why:: 
  tags:: decisions
  - ## Trade-offs
    - 
  - ## Revisit if
    - 
```

**Filled example:**
```
- 
  status:: decided
  context:: needed a task queue before the Q3 traffic spike
  options:: Celery, RQ, cloud-managed (SQS/Cloud Tasks)
  chosen:: Celery
  why:: team already knows it; keeps us cloud-portable; cheaper than managed at our scale
  tags:: decisions, python, acme
  - ## Trade-offs
    - More ops burden than managed; Redis broker adds a moving part
    - Celery's config surface is large
  - ## Revisit if
    - team grows beyond 20 people (ops burden compounds)
    - we go multi-region (managed queues make more sense)
```

A decision doc is the gift you give your future team. "Why didn't we just use X?" — they read this and don't have to re-argue.

## 8. `strikedoc` — performance documentation

**When:** You're managing someone (or a group) and need to document a pattern of missed expectations. Not for one bad day — for a pattern you've noticed across multiple instances and conversations.

**This is a page, not a journal block.** Unlike other powertags, a strikedoc accumulates over time. Create it as its own page (e.g. `strikedoc/alice` or `strikedoc/backend-team`) and append to it as observations happen.

**Template** (`/template strikedoc`):
```
- 
  about:: 
  status:: monitoring
  tags:: private
  - ## Observations
    - 
  - ## Expectations vs reality
    - 
  - ## Conversations had
    - 
  - ## Next steps
    - 
```

`status::` values: `monitoring` (early pattern), `escalated` (formal conversations started), `resolved` (improved or exited).

**Filled example:**
```
- 
  about:: [[people/alice]]
  status:: monitoring
  tags:: private
  - ## Observations
    - Jun 2 — missed sprint commitment for third sprint in a row; no blockers raised
    - Jun 9 — PR review turnaround consistently 3-4 days; team average is 1 day
    - Jun 11 — skipped stand-up again without notice (4th time this month)
  - ## Expectations vs reality
    - Expected: raise blockers early, review PRs within 24h, attend standups or notify
    - Reality: pattern of silent disengagement across all three areas
  - ## Conversations had
    - May 28 — informal check-in, asked if workload was manageable. Said yes.
    - Jun 5 — 1:1, raised PR turnaround directly. Acknowledged, no change since.
  - ## Next steps
    - TODO Schedule formal expectations conversation with specific examples
    - TODO Document agreed commitments in writing after the conversation
```

**Why `tags:: private`:** if you've set up `LOGSEQ_EXCLUDE_TAGS=private` in your MCP config, this page is invisible to AI agents. Strikedocs should never surface in searches, hub queries, or agent-generated summaries.

**For a team:** use `about:: backend-team` or `about:: [[people/alice]], [[people/bob]]` to track a group pattern. Same template, same privacy.

**No hub page, no slash command.** You don't want a strikedoc dashboard or an autocomplete shortcut. These are sensitive. Create the page manually when you need it.

---

## Entity aggregation explained

Every powertag uses **the person/entity as the aggregator** rather than dedicated series/index pages.

**Example:**
- You meet with Bob every Tuesday
- Each meeting is its own block on that day's journal, tagged with `attendees:: [[people/Bob]]`
- Open `people/Bob` → backlinks show every meeting, automatically
- **You never created a "Bob 1:1 series" page** — the person *is* the series

Same logic everywhere:
- Every `python/celery` page tagged with `tags:: incidents` shows on both the python hub AND the incidents hub
- Every brag tagged with `tags:: acme` shows on both [[brag]] AND [[acme]]
- A single note can live on as many hubs as you tag it for

Stop building manual indexes. Let backlinks do the work.

---

## Adding your own powertag

Two things to set up (~5 minutes):

1. **A template** in `[[templates]]` page — defines the field structure and carries the tag
2. **A hub page** (optional but recommended) — `{{query [[your-tag]]}}` aggregator

See [05-extend.md](05-extend.md) for the full walkthrough.

---

## Next: [04-daily-flow.md](04-daily-flow.md) — what a typical day looks like

Theory's done. Now see the system in motion.
