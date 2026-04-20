# mac-notifications

macOS system sounds for Claude Code lifecycle events.

## Sounds

| Event | Sound | Trigger |
|-------|-------|---------|
| `Stop` | Glass | Claude finishes responding |
| `TaskCompleted` | Morse | A task completes (lighter than Stop) |
| `Notification` | Ping | Idle prompt, auth success, or elicitation dialog |
| `PermissionRequest` | Tink | Claude requests tool approval |

## Requirements

- macOS (uses `afplay` and `/System/Library/Sounds/`)
- `jq` recommended (grep fallback included)

## Installation

Install via the marketplace from the repo root:

```bash
claude plugin install mac-notifications
```

Or reference directly in your Claude Code settings.

## How It Works

Each hook passes the Claude Code event payload to `hooks/scripts/play-sound.sh <SoundName>`.
The script exits silently if the sound file is missing or if `stop_hook_active` is `true` in the payload.
