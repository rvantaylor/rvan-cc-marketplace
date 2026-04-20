# rvan-cc-marketplace

Ryan Taylor's personal Claude Code plugin marketplace.

## Plugins

| Plugin | Description | Category |
|--------|-------------|----------|
| [mac-notifications](plugins/mac-notifications/) | macOS system sounds for Claude Code lifecycle events | productivity |

## Install a Plugin

```bash
claude plugin install mac-notifications --source https://github.com/rvantaylor/rvan-cc-marketplace
```

## Local Development

Clone and reference a plugin locally:

```bash
git clone https://github.com/rvantaylor/rvan-cc-marketplace
cd rvan-cc-marketplace
# Then add the plugin path to your Claude Code settings manually
```

## Validation

To validate a plugin's structure:

```bash
cat plugins/mac-notifications/.claude-plugin/plugin.json | python3 -m json.tool
cat plugins/mac-notifications/hooks/hooks.json | python3 -m json.tool
cat .claude-plugin/marketplace.json | python3 -m json.tool
```
