#!/usr/bin/env bash

# Drain stdin (SessionEnd delivers a payload we don't need)
cat > /dev/null

# Dynamically resolve Python user scripts dir — no hardcoded paths
PYTHON_SCRIPTS=$(python3 -c 'import sysconfig; print(sysconfig.get_path("scripts"))' 2>/dev/null || true)
if [ -n "$PYTHON_SCRIPTS" ]; then
  export PATH="$PYTHON_SCRIPTS:$PATH"
fi

pkill -f 'phoenix serve' || true

exit 0
