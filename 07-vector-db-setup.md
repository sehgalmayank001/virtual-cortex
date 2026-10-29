# mcp-logseq Vector Search Setup (Mac, Tested)

Semantic search over your Logseq graph using local AI embeddings. Everything runs on your machine — no data leaves it.

---

## What You're Setting Up

- **Ollama** — runs the embedding model locally
- **mcp-logseq** — MCP server that gives your agent read/write access to Logseq + semantic search
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

1. In Logseq: **Settings → Features → "Enable HTTP APIs server"**
2. Click the **plug icon** in the toolbar → **"Start server"**
3. In the API panel → **"Authorization tokens"** → create a token
4. Copy the token — you'll need it in your agent's MCP config below

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

**Rules for this file:**
- Absolute paths are safest. `~` is expanded, but `$HOME` is not
- The space in `Mobile Documents` is fine inside a JSON string — do not escape it
- `db_path` must be **outside** your iCloud folder (the path above is correct)
- If using `nomic-embed-text`, change the model value to `"nomic-embed-text"`
- Optional: `vector.exclude_tags` keeps pages out of the index only (they stay readable), and `vector.max_chunk_length` (default `10000`) skips oversized blocks

**Hosted embeddings instead of Ollama:** replace the `embedder` block with `{"provider": "openai", "model": "text-embedding-3-small", "api_key_env": "OPENAI_API_KEY"}`. The index stays local, but your note text is sent to the provider. See the upstream [VECTOR_SEARCH.md](https://github.com/ergut/mcp-logseq/blob/main/VECTOR_SEARCH.md) for OpenAI-compatible endpoints.

Validate the JSON before continuing:
```bash
python3 -c "import json; json.load(open('/Users/yourname/.logseq-vector/config.json')); print('valid JSON')"
```

If it prints `valid JSON` you're good. If it errors, check for trailing commas or backslashes.

---

## Step 3 — Run the First Sync

This builds the vector index. It reads your notes straight from disk, chunks them, and embeds each chunk. Run it once before using your agent. The sync only needs the config file, not the Logseq token.

```bash
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
- `LOGSEQ_API_TOKEN` is required (the server won't start without it). `LOGSEQ_CONFIG_FILE` is what turns on the vector tools. `LOGSEQ_API_URL` defaults to `http://localhost:12315`, but keep it explicit

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

## Step 6 — Configure Codex (optional)

Add to `~/.codex/config.toml`:

```toml
[mcp_servers.mcp-logseq]
command = "uv"
args = ["run", "--with", "mcp-logseq[vector]", "python", "-c", "from mcp_logseq import main; main()"]

[mcp_servers.mcp-logseq.env]
LOGSEQ_API_TOKEN = "your_token_here"
LOGSEQ_API_URL = "http://localhost:12315"
LOGSEQ_CONFIG_FILE = "/Users/yourname/.logseq-vector/config.json"
```

Keep the server name `mcp-logseq` — the skills call its tools by that name. Restart Codex after saving.

---

## Step 7 — Configure OpenCode (optional)

Add to `~/.config/opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "mcp-logseq": {
      "type": "local",
      "command": ["uv", "run", "--with", "mcp-logseq[vector]", "python", "-c", "from mcp_logseq import main; main()"],
      "enabled": true,
      "environment": {
        "LOGSEQ_API_TOKEN": "your_token_here",
        "LOGSEQ_API_URL": "http://localhost:12315",
        "LOGSEQ_CONFIG_FILE": "/Users/yourname/.logseq-vector/config.json"
      }
    }
  }
}
```

---

## Re-adding or Updating the MCP Config

Claude Desktop, Codex, and OpenCode read plain config files: edit the file and restart the app. The rest of this section is for Claude Code, where you change the token, args, or env vars by removing and re-adding the server.

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

To upgrade mcp-logseq itself, see [08-updating-mcp-logseq.md](08-updating-mcp-logseq.md).

---

## Verify It's Working

In your agent, ask:

> "What's the status of my Logseq vector DB?"

It will call `vector_db_status` and report chunk count, page count, and last sync time. If you see that, everything is wired up correctly.

Then try a semantic search:

> "Find my notes about [any topic you've written about]"

---

## What Your Agent Can Now Do

| Ask your agent | What happens |
|---|---|
| "Find my notes about X" | Hits vector DB — semantic search |
| "What did I write about Y last month?" | Hits vector DB |
| "Save this to Logseq as a new page" | Writes via Logseq API |
| "Append this to my page on Z" | Writes via Logseq API |
| "Is my search index up to date?" | Calls `vector_db_status` |
| "Sync the vector DB" | Prints the `logseq_sync` command to run. It does not sync (see below) |

`vector_search` works with Logseq closed. Every other tool, reads included, goes through the Logseq HTTP API, so Logseq must be **open with the API server started**.

---

## Keeping the Index Fresh

The MCP server never writes to the index. The `logseq_sync` CLI is the only writer: `vector_search` just prefixes its results with a staleness note, and `sync_vector_db` only returns the commands to run. If you skip this step, the index stays frozen at your last manual sync.

Keep a watcher running:

```bash
export LOGSEQ_CONFIG_FILE=/Users/yourname/.logseq-vector/config.json

uv run --with "mcp-logseq[vector]" python -m mcp_logseq.bin.logseq_sync --watch
```

It syncs once, then re-embeds only the files that change, until you stop it with Ctrl+C. Leave it running in a terminal tab, or run `--once` whenever `vector_db_status` reports the index out of date.

---

## Troubleshooting

### "LOGSEQ_API_TOKEN environment variable required"
The MCP server started without a token. Add `LOGSEQ_API_TOKEN` to the server's env block in your agent's config. (The `logseq_sync` CLI doesn't need it, only `LOGSEQ_CONFIG_FILE`.)

### "Invalid \escape" in config parsing
Your config file has bad JSON — usually a backslash, for example from escaping the space in `Mobile Documents` or a Windows-style path. Use forward slashes and no escapes. Validate with:
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

### Vector tools not appearing in your agent
The server logs to stderr, which your agent captures. To get a file you can read, add these to the server's env block and restart the agent:
```
LOGSEQ_LOG_FILE=/Users/yourname/.logseq-vector/mcp-logseq.log
LOGSEQ_LOG_LEVEL=DEBUG
```
Then:
```bash
grep -i vector ~/.logseq-vector/mcp-logseq.log
```
You should see: `Vector search tools registered (3 tools)`

### Changed embedding model, provider, or dimensions after first sync
```bash
uv run --with "mcp-logseq[vector]" python -m mcp_logseq.bin.logseq_sync --rebuild
```
This drops the old DB and re-indexes from scratch. Required whenever the provider, model, or `dimensions` changes; rotating an API key doesn't need it.

### "Operation not permitted" on iCloud path
Go to **System Settings → Privacy & Security → Full Disk Access**, add your terminal app, restart terminal.
