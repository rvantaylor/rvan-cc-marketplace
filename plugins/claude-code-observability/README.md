# claude-code-observability

Local Arize Phoenix lifecycle management and MCP server for Claude Code.

**What it does:**
- Starts a local [Arize Phoenix](https://github.com/Arize-ai/phoenix) server on `SessionStart` and stops it on `SessionEnd`.
- Bundles the `@arizeai/phoenix-mcp` MCP server so you can query traces, prompts, datasets, and experiments from inside Claude Code.

---

## Required companion plugin

This plugin manages the Phoenix server lifecycle. It does **not** emit traces. Traces are produced by:

```
claude-code-tracing@arize-claude-plugin
```

Without it, no spans are written. Install:

```
/plugin marketplace add arize-ai/arize-claude-code-plugin
/plugin install claude-code-tracing@arize-claude-plugin
```

---

## Prerequisites

- **Python:** `pip install --user arize-phoenix` (provides the `phoenix` CLI)
- **Node ≥ 18:** Required for `npx` to fetch `@arizeai/phoenix-mcp` on first use
- **macOS:** The `claude-code-observability-open` skill uses `open` (macOS-only)

---

## Required env block

Add to `~/.claude/settings.json` (global) or `.claude/settings.json` (project):

```json
"env": {
  "PHOENIX_ENDPOINT": "http://localhost:6006",
  "ARIZE_TRACE_ENABLED": "true",
  "ARIZE_PROJECT_NAME": "<your-project>"
}
```

Replace `<your-project>` with your project name (e.g. `my-app`). This env block wires `claude-code-tracing` to point at the local Phoenix instance.

---

## Session lifecycle

- **SessionStart:** `phoenix-start.sh` checks if Phoenix is already running (`pgrep -f 'phoenix serve'`). If not, starts it in the background: `nohup phoenix serve >> /tmp/phoenix.log 2>&1 &`. Exits 0 on all paths.
- **SessionEnd:** `phoenix-stop.sh` kills Phoenix via `pkill -f 'phoenix serve'`. Exits 0 on all paths.

**Multi-session caveat:** Closing any Claude Code session kills Phoenix for all other open sessions. If this happens, open a new session (retriggers the start hook) or run `phoenix serve &` manually in a terminal.

---

## MCP server

The bundled `phoenix` MCP server connects to `http://localhost:6006`. It exposes tools for querying traces, prompts, datasets, and experiments. See [`@arizeai/phoenix-mcp`](https://github.com/Arize-ai/phoenix) for the full tool list.

---

## Skills

| Skill | Trigger phrases |
|-------|----------------|
| `claude-code-observability-status` | "is phoenix running", "phoenix status", "check phoenix", "is the phoenix server up" |
| `claude-code-observability-open` | "open phoenix", "open the phoenix ui", "show phoenix", "view traces in phoenix" |

---

## Troubleshooting

**Check logs:**
```bash
tail -f /tmp/phoenix.log
```

**Check if Phoenix is running:**
```bash
pgrep -f 'phoenix serve'
```

**Install Phoenix:**
```bash
pip install --user arize-phoenix
```
