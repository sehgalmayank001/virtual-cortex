# Daily flow — the system in motion

You've set up the templates, hubs, and slash commands. Here's what it looks like once they disappear into muscle memory.

---

## The rhythm

| When | What | Time |
|------|------|------|
| Morning | Skim yesterday's open TODOs and any `## Followups` from incidents | 2 min |
| During the day | Capture in the journal as things happen — meetings, brags, decisions, observations | 30 sec each |
| End of day | Skim the journal, tag anything important you missed | 1 min |
| Weekly | Visit hubs, close resolved incidents, update brags with results | 5 min |

That's the whole loop. Everything else is detail.

---

## Finding things later

In order of preference:

1. **Hubs** — if you remember the type (meeting? decision? incident?), go to the hub
2. **Person pages** — `people/Bob` shows everything you've done with Bob
3. **Tag pages** — `[[acme]]` shows everything tagged with acme
4. **Logseq search** (`Cmd+K`) — last resort, but Logseq's full-text search is fast

Most days you'll never need #4.

---

## Real-world examples

### Planning a 1:1

Before the 1:1 with Bob, click `people/Bob`. See the last three 1:1 blocks. Skim the action items assigned to him. Note any that are open. That's your agenda starter — no prep doc needed.

### Writing a performance review

End of quarter. Open `brag`. See 14 entries. Group by `tags::` (acme vs personal). Cherry-pick the top 5 for the review document. Total prep time: 20 minutes instead of "what did I even do this quarter."

### Postmortem on an incident

Production was down for 40 minutes Tuesday. Open the incident block in Tuesday's journal. Timeline is already there because you captured as you went. Root cause and fix were filled in once you understood the issue. Copy-paste the structured sections into the postmortem doc. 10 minutes instead of an hour.

### Re-arguing a decision

A new engineer asks "why are we using Celery instead of SQS?" Send them the link to the decision block. Don't re-explain. If they have new arguments, add them to `## Revisit if`. The system gets better with use.

### Onboarding someone to your team's context

New hire starts Monday. Point them at your company hub (`acme/`). They see every decision, every incident, every meeting with context — structured and queryable. Beats a stale Confluence wiki.

---

## What makes it stick

1. **Capture in the journal, not on dedicated pages.** Lower friction = higher capture rate.
2. **Tag aggressively but accurately.** Multiple tags per block is fine. Inventing new tags every week is not.
3. **Trust the hubs.** Don't manually maintain index pages — the queries do that.
4. **Don't backfill.** Don't try to import 6 months of old notes. Start from today. The system gets dense fast.
5. **Skip what doesn't fit.** Not every meeting needs a template. Not every win needs a brag. The system bends to you.

---

## Next: [05-extend.md](05-extend.md) — adding your own powertags

You'll want to extend the system. Here's how to do it without breaking it.
