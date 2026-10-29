# Updating mcp-logseq

The setup configs don't pin a version, so `uv` should fetch the latest [mcp-logseq](https://github.com/ergut/mcp-logseq) release. Two things can hold you on an old one.

## 1. uv's cache

`uv` reuses what it already downloaded, so an agent can keep starting an old release. Clear it and restart your agent:

```bash
uv cache clean mcp-logseq
```

## 2. A leftover `mcp<2` pin

If your agent's config has `--with "mcp<2"` in the args, remove it. It was a workaround for a crash in older releases. mcp-logseq 1.9.0+ requires mcp 2, so the pin silently holds you on 1.8.0.

Check every agent you configured:

| Agent | Config |
|---|---|
| Claude Code | `claude mcp get mcp-logseq` (to change it, remove and re-add — see [07-vector-db-setup.md](07-vector-db-setup.md#re-adding-or-updating-the-mcp-config)) |
| Claude Desktop | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Codex | `~/.codex/config.toml` |
| OpenCode | `~/.config/opencode/opencode.json` |

## Check which version you're running

```bash
uv run --with "mcp-logseq[vector]" python -c "import importlib.metadata as m; print(m.version('mcp-logseq'))"
```

Compare it with the [latest release](https://github.com/ergut/mcp-logseq/releases).

## After upgrading with vector search

- Run one sync: `logseq_sync --once` (full command in [07-vector-db-setup.md](07-vector-db-setup.md#keeping-the-index-fresh)). Since 1.9.2 the sync skips the graph's `logseq/bak/` backups and `logseq/.recycle/` deleted pages, so the first run after upgrading can report a large "deleted" count while it removes them from the index.
- The MCP server doesn't sync the index itself. Keep `logseq_sync --watch` running, or run `--once` when `vector_db_status` says the index is out of date.
