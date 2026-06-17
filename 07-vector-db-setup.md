# mcp-logseq Vector Search Setup (Mac, Tested)

Semantic search over your Logseq graph using local AI embeddings. Everything runs on your machine — no data leaves it.

---

## What You're Setting Up

- **Ollama** — runs the embedding model locally
- **mcp-logseq** — MCP server that gives Claude read/write access to Logseq + semantic search
- **LanceDB** — local vector database that stores your note embeddings
- **Config file** — wires everything together

---

## Prerequisites

### 1. Ollama

Install from [ollama.com](https://ollama.com), then pull the embedding model.

**On M-series Mac with 16GB+ RAM, use the high-quality model:**
```bash
ollama pull qwen3-embedding:8b
```

This is a ~5GB download. It uses ~6–7GB RAM at runtime, which is fine on 16GB+ unified memory.

**On older Mac or less RAM, use the lighter model:**
```bash
ollama pull nomic-embed-text
```

Confirm Ollama is running:
```bash
curl http://localhost:11434/api/embed -d '{"model":"qwen3-embedding:8b","input":["test"]}'
```

You should get back a JSON response with an `embeddings` array — not an error.

### 2. Logseq API Token

The MCP server needs a token to talk to Logseq's local HTTP API.

1. Open Logseq
2. Go to **Settings → Developer → HTTP APIs**
3. Enable the API server
4. Copy the token — you'll need it in multiple places below

### 3. Find Your Logseq Graph Path

You need the **absolute path** to the specific graph folder you want to index (the one containing `pages/` and `journals/`).

```bash
ls ~/Library/Mobile\ Documents/iCloud~com~logseq~logseq/Documents/
```

This lists your graphs. Pick the one you want, then confirm it looks right:

```bash
ls ~/Library/Mobile\ Documents/iCloud~com~logseq~logseq/Documents/YOUR_GRAPH_NAME
```

You should see folders like `pages/`, `journals/`, `assets/`.

> **iCloud note:** If the `ls` command returns `Operation not permitted`, go to **System Settings → Privacy & Security → Full Disk Access** and add your terminal app (Terminal or iTerm2), then restart the terminal.

Get the full path:
```bash
cd ~/Library/Mobile\ Documents/iCloud~com~logseq~logseq/Documents/YOUR_GRAPH_NAME
pwd
```

Copy the output — this is your `logseq_graph_path`. It will look like:
```
/Users/yourname/Library/Mobile Documents/iCloud~com~logseq~logseq/Documents/YOUR_GRAPH_NAME
```

---

## Step 1 — Install mcp-logseq

No virtual environment needed. `uv` handles isolation automatically.

```bash
uv run --with "mcp-logseq[vector]" python -c "import mcp_logseq; print('ok')"
```

If that prints `ok`, the install works.

---

## Step 2 — Create the Config File

```bash
mkdir -p ~/.logseq-vector
nano ~/.logseq-vector/config.json
```

Paste this, filling in your actual values:

```json
{
  "logseq_graph_path": "/Users/yourname/Library/Mobile Documents/iCloud~com~logseq~logseq/Documents/YOUR_GRAPH_NAME",
  "exclude_tags": ["private"],
  "vector": {
    "enabled": true,
    "db_path": "/Users/yourname/.logseq-vector/db",
    "embedder": {
      "provider": "ollama",
      "model": "qwen3-embedding:8b",
      "base_url": "http://localhost:11434"
    },
    "include_journals": true,
    "min_chunk_length": 50
  }
}
```

**Critical rules for this file:**
- Use **absolute paths only** — no `~`, no `$HOME`
- The space in `Mobile Documents` is fine inside a JSON string — do not escape it
- `db_path` must be **outside** your iCloud folder (the path above is correct)
- If using `nomic-embed-text`, change the model value to `"nomic-embed-text"`

Validate the JSON before continuing:
```bash
python3 -c "import json; json.load(open('/Users/yourname/.logseq-vector/config.json')); print('valid JSON')"
```

If it prints `valid JSON` you're good. If it errors, check for trailing commas or backslashes.

---

## Step 3 — Run the First Sync

This builds the vector index. It reads your notes, chunks them, and embeds each chunk. Run it once before using Claude.

```bash
export LOGSEQ_API_TOKEN=your_token_here
export LOGSEQ_API_URL=http://localhost:12315
export LOGSEQ_CONFIG_FILE=/Users/yourname/.logseq-vector/config.json

uv run --with "mcp-logseq[vector]" python -m mcp_logseq.bin.logseq_sync --once
```

**This takes time.** With `qwen3-embedding:8b` and a large graph, expect 15–30 minutes. You'll see batch progress in the terminal. Normal.

Check status when done:
```bash
uv run --with "mcp-logseq[vector]" python -m mcp_logseq.bin.logseq_sync --status
```

---

## Step 4 — Configure Claude Desktop

Open Claude Desktop config:
```bash
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Add the `mcp-logseq` entry, filling in your actual token and username:

```json
{
  "mcpServers": {
    "mcp-logseq": {
      "command": "uv",
      "args": [
        "run",
        "--with",
        "mcp-logseq[vector]",
        "python",
        "-c",
        "from mcp_logseq import main; main()"
      ],
      "env": {
        "LOGSEQ_API_TOKEN": "your_token_here",
        "LOGSEQ_API_URL": "http://localhost:12315",
        "LOGSEQ_CONFIG_FILE": "/Users/yourname/.logseq-vector/config.json"
      }
    }
  }
}
```

**Key differences from the official docs:**
- No `cwd` field — not needed when installed from PyPI
- `.[vector]` becomes `mcp-logseq[vector]` — the dot syntax only works in a source checkout
- All three env vars are required — missing any one of them causes a startup error

Restart Claude Desktop after saving.

---

## Step 5 — Configure Claude Code (optional)

If you use Claude Code instead of or alongside Claude Desktop:

```bash
claude mcp remove mcp-logseq -s local 2>/dev/null; claude mcp add-json mcp-logseq '{
  "command": "uv",
  "args": ["run", "--with", "mcp-logseq[vector]", "python", "-c", "from mcp_logseq import main; main()"],
  "env": {
    "LOGSEQ_API_TOKEN": "your_token_here",
    "LOGSEQ_API_URL": "http://localhost:12315",
    "LOGSEQ_CONFIG_FILE": "/Users/yourname/.logseq-vector/config.json"
  }
}' -s local
```

Verify:
```bash
claude mcp get mcp-logseq
```

---

## Re-adding or Updating the MCP Config

If you need to change the token, fix the args, or update any env var — you cannot edit in place. You must remove and re-add.

**Always remove first:**
```bash
claude mcp remove mcp-logseq -s local
```

Confirm it's gone:
```bash
claude mcp get mcp-logseq
# should say: MCP server "mcp-logseq" not found
```

Then add again with the corrected config:
```bash
claude mcp add-json mcp-logseq '{
  "command": "uv",
  "args": ["run", "--with", "mcp-logseq[vector]", "python", "-c", "from mcp_logseq import main; main()"],
  "env": {
    "LOGSEQ_API_TOKEN": "your_token_here",
    "LOGSEQ_API_URL": "http://localhost:12315",
    "LOGSEQ_CONFIG_FILE": "/Users/yourname/.logseq-vector/config.json"
  }
}' -s local
```

Confirm it looks right:
```bash
claude mcp get mcp-logseq
```

Check that `Args` shows `--with mcp-logseq[vector]` and all three env vars are present. If anything looks wrong, remove and re-add again — there is no edit command.

> **Common mistake:** Running `add-json` when the server already exists gives `MCP server mcp-logseq already exists` and silently keeps the old config. Always remove first.

---

## Verify It's Working

In Claude Desktop or Claude Code, ask:

> "What's the status of my Logseq vector DB?"

Claude will call `vector_db_status` and report chunk count, page count, and last sync time. If you see that, everything is wired up correctly.

Then try a semantic search:

> "Find my notes about [any topic you've written about]"

---

## What Claude Can Now Do

| Ask Claude | What happens |
|---|---|
| "Find my notes about X" | Hits vector DB — semantic search |
| "What did I write about Y last month?" | Hits vector DB |
| "Save this to Logseq as a new page" | Writes via Logseq API |
| "Append this to my page on Z" | Writes via Logseq API |
| "Is my search index up to date?" | Calls `vector_db_status` |
| "Sync the vector DB" | Runs incremental re-embed |

Logseq must be **open and running** for write operations. Read and vector search work without it.

---

## Keeping the Index Fresh

The MCP server auto-syncs in the background when you run a search and files have changed. For continuous sync without waiting:

```bash
export LOGSEQ_API_TOKEN=your_token_here
export LOGSEQ_API_URL=http://localhost:12315
export LOGSEQ_CONFIG_FILE=/Users/yourname/.logseq-vector/config.json

uv run --with "mcp-logseq[vector]" python -m mcp_logseq.bin.logseq_sync --watch
```

This watches for file changes and re-embeds only what changed.

---

## Troubleshooting

### "LOGSEQ_API_TOKEN environment variable required"
All three env vars must be set before running any sync command:
```bash
export LOGSEQ_API_TOKEN=...
export LOGSEQ_API_URL=http://localhost:12315
export LOGSEQ_CONFIG_FILE=/Users/yourname/.logseq-vector/config.json
```

### "Invalid \escape" in config parsing
Your config file has bad JSON — usually caused by using `~` in paths or a backslash in a Windows-style path. Use absolute paths with forward slashes only. Validate with:
```bash
python3 -c "import json; json.load(open('/Users/yourname/.logseq-vector/config.json'))"
```

### "Vector search not configured — skipping vector tools"
Either `LOGSEQ_CONFIG_FILE` is not set in the MCP server env, or the config JSON failed to parse (see above), or `vector.enabled` is not `true`.

### "Cannot connect to Ollama"
```bash
ollama list        # confirm it's running
ollama pull qwen3-embedding:8b   # confirm model is downloaded
```

### Vector tools not appearing in Claude
Check the log:
```bash
cat ~/.cache/mcp-logseq/mcp_logseq.log | grep -i vector
```
You should see: `Vector search tools registered (3 tools)`

### Changed embedding model after first sync
```bash
uv run --with "mcp-logseq[vector]" python -m mcp_logseq.bin.logseq_sync --rebuild
```
This drops the old DB and re-indexes from scratch. Required any time you switch models.

### "Operation not permitted" on iCloud path
Go to **System Settings → Privacy & Security → Full Disk Access**, add your terminal app, restart terminal.
