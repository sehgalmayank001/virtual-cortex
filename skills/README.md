# Skills — AI agents for setup, capture, and review

Seven ready-to-run AI agent skills for the Logseq Knowledge System. These work with [Claude Code](https://claude.ai/code), Cursor, or any Claude-compatible agent.

## What's included

| Skill | What it does |
|-------|--------------|
| [virtual-cortex-setup](virtual-cortex-setup/) | **Start here.** Verifies MCP connection, scans your graph, creates hub pages, templates, and slash commands in one guided run. Invoke with `/virtual-cortex-setup`. |
| [graph-init](graph-init/) | Scans your existing graph, discovers tags you already use, maps them to powertags, and suggests how to bridge old and new conventions. |
| [meeting-sync](meeting-sync/) | Syncs meeting notes from any transcript tool (Granola, Otter, Fireflies, etc.) into the day's Logseq journal — structured, tagged, with attendees auto-linked to `people/<name>` pages |
| [logseq-note](logseq-note/) | Saves arbitrary discussion notes from an AI agent session into Logseq — suggests the right hub and journal-or-page placement based on content |
| [weekly-review](weekly-review/) | Generates a weekly review by scanning the last 7 days of journal entries. Pulls brags, decisions, completed/open TODOs, meetings, incidents into a structured block |
| [meeting-prep](meeting-prep/) | Before a meeting with person X, surfaces the last 3 meetings + open action items in both directions. "I look prepared without trying." |
| [brag-finder](brag-finder/) | Scans journal for work wins the user forgot to log as `#brag`. Suggests candidates, user confirms which to add. Performance-review prep. |

All seven integrate with the same Logseq structure the bundle defines — they read from and write to the conventions in [02-mental-model.md](../02-mental-model.md).

---

## How to install

Skills are markdown files with frontmatter. They load automatically into compatible AI agents from a known directory.

> **Keep the `assets/` folder.** `cp -r skills/*` copies an `assets/` folder alongside the skill folders. The setup skills (`virtual-cortex-setup`, `graph-init`) read their ready-made hub pages, templates, and config from there, so it must stay next to the skills in your skills directory. Without it, the setup skills have nothing to build from.
>
> `skills/assets/` is a mirror of the bundle's top-level `assets/`. If you customise the canonical files, re-run `scripts/sync-assets.sh` to refresh the mirror before installing.

### For Claude Code (CLI)

```bash
cp -r skills/* ~/.claude/skills/
```

Restart your Claude Code session. The skills are now invokable by name (e.g. `/weekly-review`).

### For other Claude-compatible tools

Most tools that support Claude skills look for `SKILL.md` files in a configurable directory. Check your tool's docs, then copy as above.

### For `~/.agents/skills/` (alternative location)

If your tooling looks at `~/.agents/skills/` instead:

```bash
cp -r skills/* ~/.agents/skills/
```

---

## MCP setup (required for all skills)

The skills read and write to your Logseq graph via [mcp-logseq](https://github.com/ergut/mcp-logseq). Without it, the skills can't do anything. Set this up before installing the skills.

### Prerequisites

- **Logseq desktop** running
- **[uv](https://docs.astral.sh/uv/)** installed (Python package manager)

### Step 1 — Enable the Logseq HTTP API

1. In Logseq: **Settings** → **Features** → check **"Enable HTTP APIs server"**
2. Click the **API button (plug icon)** in the toolbar → **"Start server"**
3. In the API panel → **"Authorization tokens"** → create a new token
4. Copy the token — you'll need it in Step 2

The API server must be running whenever you use the skills. If you restart Logseq, you may need to click "Start server" again.

### Step 2 — Add mcp-logseq to your agent

#### Claude Code

```bash
claude mcp add mcp-logseq \
  --env LOGSEQ_API_TOKEN=your_token_here \
  --env LOGSEQ_API_URL=http://localhost:12315 \
  -- uv run --with mcp-logseq mcp-logseq
```

#### Cursor

Add to your MCP config (Settings → MCP → Add Server):

```json
{
  "mcpServers": {
    "mcp-logseq": {
      "command": "uv",
      "args": ["run", "--with", "mcp-logseq", "mcp-logseq"],
      "env": {
        "LOGSEQ_API_TOKEN": "your_token_here",
        "LOGSEQ_API_URL": "http://localhost:12315"
      }
    }
  }
}
```

#### Claude Desktop

Add to your config file (`Settings → Developer → Edit Config`):

```json
{
  "mcpServers": {
    "mcp-logseq": {
      "command": "uv",
      "args": ["run", "--with", "mcp-logseq", "mcp-logseq"],
      "env": {
        "LOGSEQ_API_TOKEN": "your_token_here",
        "LOGSEQ_API_URL": "http://localhost:12315"
      }
    }
  }
}
```

**"spawn uv ENOENT" error?** Claude Desktop can't find `uv`. Use the full path instead:

```bash
which uv
```

Common locations: `~/.local/bin/uv` (curl install), `/opt/homebrew/bin/uv` (Homebrew). Replace `"command": "uv"` with the full path.

### Step 3 — Verify the connection

In your agent, ask:

```
List my Logseq pages
```

If it returns a page list, you're connected. If it errors, check:

- Logseq is running
- The API server is started (not just enabled)
- The token is correct
- Port 12315 is accessible

### Optional: Privacy exclusions

Pages tagged with excluded tags are completely hidden from the AI. Set via environment variable:

```
LOGSEQ_EXCLUDE_TAGS=private,secret
```

Any page with `tags:: private` will not appear in listings, searches, or queries.

### Meeting tool MCP (for meeting-sync)

The `meeting-sync` skill auto-detects which transcript tool you use (Granola, Otter, Fireflies, Fathom, tl;dv, etc.). Each tool needs its own MCP connector — authenticate via `/mcp` in your AI tool. If your tool doesn't have an MCP server, you can paste meeting summaries manually and the skill will structure them.

---

## When to use which

| You need to... | Use |
|----------------|-----|
| Set up the full system from scratch | `virtual-cortex-setup` |
| Bridge existing tags to the new system | `graph-init` |
| Capture a meeting note automatically | `meeting-sync` |
| Save a decision from a coding session | `logseq-note` |
| Review what you got done this week | `weekly-review` |
| Walk into a meeting prepared | `meeting-prep` |
| Find wins for performance review | `brag-finder` |

`virtual-cortex-setup` and `graph-init` run once at the start. The rest compose for daily use: `brag-finder` finds candidates, `logseq-note` saves them. `meeting-sync` captures meetings, `meeting-prep` uses them. The system gets denser with use.

---

## Customizing the skills

Both meeting-sync and meeting-prep depend on your `people/*` namespace. If you change naming conventions, edit the resolution rules at the top of each skill.

Brag-finder uses pattern-matching for win-like language. The list of phrases is in the skill — add company-specific terms ("shipped to canary", "promoted candidate") if useful.

Weekly-review extraction patterns are defined as tag/marker matches. If you rename `[[brag]]` to `[[wins]]`, update the skill accordingly.

---

## Testing the skills

After install, run each in a safe context:

```
/virtual-cortex-setup
```

Expected: verifies MCP connection, scans your graph, shows a plan for hub pages and templates, asks for confirmation before creating anything. This is the one-shot full setup.

```
/graph-init
```

Expected: scans your graph for existing tags, maps them to powertags, suggests how to bridge old and new conventions.

```
/weekly-review
```

Expected: prints last 7 days' summary, writes a block to today's journal.

```
/meeting-prep <known-person-name>
```

Expected: surfaces last 3 meetings + open TODOs in both directions.

```
/brag-finder
```

Expected: lists candidate wins from last 30 days, asks for confirmation before writing.

```
/meeting-sync
```

Expected: detects your meeting tool, lists recent meetings, syncs the most recent (or asks which one).

```
/logseq-note
```

Expected: suggests a categorization for the recent conversation, asks for confirmation, writes the note.

---

## What's not included

- **No `daily-summary` skill yet.** Daily summaries are usually noise — weekly reviews give better signal. Build it yourself if you want it.
- **No `linear-to-logseq` skill.** Linear MCP is mature; building one yourself takes ~1 hour. Skipped to keep the bundle focused.
- **No `pr-to-brag` skill.** Same — GitHub MCP exists, build for your repos. The bundle ships universal skills, not tool-specific ones.

If you build these, share them back — happy to include in v2.

---

## License

Skills are part of this bundle and follow the same license — use, adapt, share, sell adaptations. Don't claim you wrote the originals from scratch if you didn't.
