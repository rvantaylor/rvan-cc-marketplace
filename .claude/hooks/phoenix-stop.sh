#!/usr/bin/env bash

# Read hook payload from stdin; exit early if stop_hook_active is set
PAYLOAD=$(cat)
if command -v jq > /dev/null 2>&1; then
  STOP_HOOK_ACTIVE=$(echo "$PAYLOAD" | jq -r '.stop_hook_active // false')
else
  STOP_HOOK_ACTIVE=$(echo "$PAYLOAD" | grep -o '"stop_hook_active": *true' | grep -c true || true)
fi
if [ "$STOP_HOOK_ACTIVE" = "true" ] || [ "$STOP_HOOK_ACTIVE" = "1" ]; then
  exit 0
fi

# Dynamically resolve Python user scripts dir — no hardcoded paths
PYTHON_SCRIPTS=$(python3 -c 'import sysconfig; print(sysconfig.get_path("scripts"))' 2>/dev/null || true)
if [ -n "$PYTHON_SCRIPTS" ]; then
  export PATH="$PYTHON_SCRIPTS:$PATH"
fi

pkill -f 'phoenix serve' || true

exit 0
