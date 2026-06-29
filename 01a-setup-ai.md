# AI-driven setup (~10 min)

An AI agent does the heavy lifting: it connects to your graph, scans what is already there, and creates the hub pages and templates for you after showing you a plan. You approve, it builds.

If you would rather drop the files in by hand with no AI or MCP server, see [01b-setup-manual.md](01b-setup-manual.md) instead. Both paths reach the same end state. This path also scans your existing tags and merges them into the hub queries.

## What you need

- Logseq installed (desktop version) with a graph open
- An AI agent that supports skills and MCP: Claude Code, Cursor, or Claude Desktop
- **[uv](https://docs.astral.sh/uv/)**, the Python package manager. Install: `curl -LsSf https://astral.sh/uv/install.sh | sh`
- **[mcp-logseq](https://github.com/ergut/mcp-logseq)**, the MCP server that connects your agent to your graph. No separate install needed, `uv` downloads it on first run, you just add the config.

## Step 1 — Enable the Logseq HTTP API (2 min)

The MCP server talks to Logseq over its local HTTP API, so turn it on:

1. In Logseq: **Settings → Features → "Enable HTTP APIs server"**
2. Click the **plug icon** in the toolbar → **"Start server"**
3. In the API panel → **"Authorization tokens"** → create a token and copy it

The API server must be running whenever you use the skills. If you restart Logseq, you may need to click "Start server" again.

## Step 2 — Add mcp-logseq to your agent (3 min)

Add the server config to your agent, using the token from Step 1. **Full copy-paste configs for Claude Code, Cursor, and Claude Desktop are in [skills/README.md](skills/README.md).** The short version for Claude Code:

```bash
claude mcp add mcp-logseq \
  --env LOGSEQ_API_TOKEN=your_token_here \
  --env LOGSEQ_API_URL=http://localhost:12315 \
  -- uv run --with mcp-logseq mcp-logseq
```

## Step 3 — Copy the skills into your agent (1 min)

The bundle ships seven skills under `skills/`. Copy them into your agent's skills directory:

```bash
cp -r skills/* ~/.claude/skills/
```

For Cursor or other tools, see [skills/README.md](skills/README.md) for the right directory. Restart your agent session so the skills load.

## Step 4 — Verify the connection (1 min)

In your agent, ask:

```
List my Logseq pages
```

If it returns a page list, you are connected. If it errors, jump to [Troubleshooting](#troubleshooting) below before going further.

## Step 5 — Run the setup skill (2 min)

In your agent, run:

```
/virtual-cortex-setup
```

The skill will:

1. Verify the MCP connection and report your page count
2. Scan your graph for existing hubs, tags, projects, and people
3. Show you a plan: what already exists, what it will create, and which of your existing tags it will fold into the hub queries
4. Ask which hubs you want and what your project is called
5. After you confirm, create the hub pages and the `templates` page

Nothing is written until you approve the plan.

## Step 6 — Paste the slash commands (1 min)

The agent cannot edit `config.edn` for you, so at the end it shows you a `:commands` block to paste. Open `<your-graph>/logseq/config.edn`, find the `:commands` line, replace it with the block the skill prints (the same one in [`assets/config.edn`](assets/config.edn)), save, and **restart Logseq**.

## Verification, you have done it right if:

- "List my Logseq pages" returns your pages
- Your hub pages (meetings, brag, decisions, …) exist with their icons and queries
- Typing `/template brag` in a journal block inserts the full brag structure
- Typing `/attendees` inserts `attendees:: ` (after the config.edn restart)

## Troubleshooting

If "List my Logseq pages" fails:

1. Is Logseq running? Open it if not.
2. Is the HTTP API enabled? **Settings → Features → "Enable HTTP APIs server"**
3. Is the API server started (not just enabled)? Click the plug icon → "Start server".
4. Is the token correct in your agent's MCP config?
5. Is port 12315 the one your Logseq API is on?

Fix whichever step failed and run `/virtual-cortex-setup` again. The skill is safe to re-run, it detects what already exists and only creates what is missing.

**Already have content with different tag names?** Run `/graph-init` instead. It focuses on mapping your existing tags (`standup`, `retro`, `shipped`, …) to the bundle's powertags and bridging old and new conventions.

## Next: read [02-mental-model.md](02-mental-model.md) for the *why*

The setup works without understanding the model. But once you read about how content, tags, and properties fit together, the rest of the bundle makes sense and you can extend it without breaking it.
