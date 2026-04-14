#!/bin/bash
# post-push-deploy.sh — PostToolUse hook for Bash
# Triggers forge-deploy after a successful `git push` in the forge repo.
#
# Called by Claude Code PostToolUse hook with $TOOL_INPUT as argument.
# Only fires when the tool input contains "git push" (not git push --force etc.)

set -euo pipefail

TOOL_INPUT="${1:-}"
PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

# Only trigger on git push commands (not --force, which is denied)
if ! echo "$TOOL_INPUT" | grep -qE '"command".*git push'; then
  exit 0
fi

# Only trigger in forge repo (not template repo or other repos)
if [ ! -f "$PROJECT_DIR/scripts/forge-deploy.sh" ]; then
  exit 0
fi

# Run deploy pipeline (skip forge push — it just happened)
echo ""
echo "[post-push-deploy] Triggering template build + push..."
bash "$PROJECT_DIR/scripts/forge-deploy.sh" --skip-push 2>&1
