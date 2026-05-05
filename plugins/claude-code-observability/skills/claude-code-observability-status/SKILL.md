---
name: claude-code-observability-status
description: Check whether the local Arize Phoenix server is running. Use when the user asks "is phoenix running", "phoenix status", "check phoenix", or "is the phoenix server up".
---

Check the status of the local Arize Phoenix server.

1. Run `pgrep -f 'phoenix serve'` to find the PID.
2. Run `curl -sf http://localhost:6006 >/dev/null` to verify the server is reachable.
3. Report:
   - If running and reachable: PID, URL (`http://localhost:6006`), log path (`/tmp/phoenix.log`).
   - If the process exists but curl fails: report the PID but note the server is not yet responding (it may still be starting up — suggest waiting a moment and retrying).
   - If not running: report that Phoenix is not running and suggest either opening a new Claude Code session (which retriggers the SessionStart hook) or running `phoenix serve` manually in a terminal.
