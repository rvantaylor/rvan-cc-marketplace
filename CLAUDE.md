# rvan-cc-marketplace

Ryan Taylor's personal Claude Code plugin marketplace.

## Structure

```
rvan-cc-marketplace/
├── .claude-plugin/
│   └── marketplace.json       # Marketplace manifest
├── plugins/
│   └── <plugin-name>/         # One directory per plugin
│       ├── .claude-plugin/
│       │   └── plugin.json    # Plugin metadata
│       ├── hooks/
│       │   ├── hooks.json     # Hook event wiring
│       │   └── scripts/       # Shell scripts called by hooks
│       └── README.md
├── CLAUDE.md
└── README.md
```

## Adding a Plugin

1. Create `plugins/<name>/` with the structure above.
2. Add an entry to `.claude-plugin/marketplace.json` under `"plugins"`. Use the bare plugin name as `"source"` — the `pluginRoot` convention (`"./plugins"`) in `metadata` resolves it automatically.
3. Write a `README.md` for the plugin.

## pluginRoot Convention

`marketplace.json` sets `"pluginRoot": "./plugins"`. This means all `"source"` values in plugin entries are bare names (e.g. `"mac-notifications"`), not full relative paths.

## Hook Script Pattern

Hook scripts live in `plugins/<name>/hooks/scripts/`. They receive the Claude Code event payload on stdin and take any arguments from the `hooks.json` command string. Scripts should:

- Exit 0 on all paths (hooks are fire-and-forget)
- Check `stop_hook_active` in the payload when relevant and exit early if true
- Use `jq` for JSON parsing when available, with a grep fallback for portability
