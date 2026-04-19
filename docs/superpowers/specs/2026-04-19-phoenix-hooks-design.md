# Phoenix Auto-Start/Stop Hooks Design

## Overview

Two Claude Code lifecycle hooks that automatically start Arize Phoenix when a Claude Code session opens and stop it when the session ends.

## Files

```
.claude/
  settings.json          ← hooks block added to existing file
  hooks/
    phoenix-start.sh     ← idempotent start, async background launch
    phoenix-stop.sh      ← kills any running phoenix serve process
```

## Hook Configuration

Added to `.claude/settings.json` under a `"hooks"` key:

- **SessionStart** with `matcher: "startup"` — fires only on fresh session open (not resume/clear/compact)
- **SessionEnd** with no matcher — fires on any session termination
- Start hook uses `async: true` so Phoenix launches in background without blocking session startup
- Stop hook is synchronous (default) to ensure cleanup before exit

## Scripts

### `phoenix-start.sh`

1. Dynamically resolves Python user scripts dir via `python3 -c 'import sysconfig; ...'` and prepends to PATH — no hardcoded paths
2. Checks if `phoenix serve` is already running via `pgrep -f`
3. If not running: launches `nohup phoenix serve >> /tmp/phoenix.log 2>&1 &`
4. Exits 0 always

### `phoenix-stop.sh`

1. Same dynamic PATH resolution
2. Runs `pkill -f 'phoenix serve'`
3. Ignores non-zero exit (process may already be gone)
4. Exits 0 always

## Constraints

- Phoenix port is 6006 (matches existing `PHOENIX_ENDPOINT=http://localhost:6006` in settings.json)
- Stop hook always kills Phoenix regardless of how it was started
- Scripts must be `chmod +x` to execute
- Both scripts committed to `.claude/hooks/` in `settings.json` (shared, not local)
