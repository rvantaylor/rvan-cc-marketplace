#!/usr/bin/env bash

# Drain stdin (SessionStart delivers a payload we don't need)
cat > /dev/null

# Dynamically resolve Python user scripts dir — no hardcoded paths
PYTHON_SCRIPTS=$(python3 -c 'import sysconfig; print(sysconfig.get_path("scripts"))' 2>/dev/null || true)
if [ -n "$PYTHON_SCRIPTS" ]; then
  export PATH="$PYTHON_SCRIPTS:$PATH"
fi

# Surface a helpful hint if phoenix CLI is missing
if ! command -v phoenix > /dev/null 2>&1; then
  echo "[claude-code-observability] phoenix CLI not found — install with: pip install --user arize-phoenix" >&2
  exit 0
fi

# Idempotent: only start if not already running
if pgrep -f 'phoenix serve' > /dev/null 2>&1; then
  exit 0
fi

nohup phoenix serve >> /tmp/phoenix.log 2>&1 &

exit 0
