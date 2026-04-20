#!/bin/bash
SOUND_NAME="${1:-Glass}"
SOUND_FILE="/System/Library/Sounds/${SOUND_NAME}.aiff"
[ -f "$SOUND_FILE" ] || exit 0
INPUT=$(cat)
if command -v jq > /dev/null 2>&1; then
  echo "$INPUT" | jq -e '.stop_hook_active == true' > /dev/null 2>&1 && exit 0
else
  echo "$INPUT" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
fi
afplay "$SOUND_FILE" &
exit 0
