#!/bin/bash
# forge-deploy.sh — Push forge + build template + push template
#
# Usage:
#   ./scripts/forge-deploy.sh              # Push forge, build, push template
#   ./scripts/forge-deploy.sh --skip-push  # Build + push template only (forge already pushed)
#
# Called automatically by PostToolUse hook on `git push` in the forge repo,
# or manually after committing changes.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE_DIR="${TEMPLATE_DIR:-$PROJECT_DIR/../claude-code-harness-template}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SKIP_PUSH=false
for arg in "$@"; do
  case "$arg" in
    --skip-push) SKIP_PUSH=true ;;
  esac
done

# Guard: must be in forge repo
if [ ! -f "$PROJECT_DIR/scripts/build-template.sh" ]; then
  echo -e "${RED}✗ Not in harness-forge repo${NC}" >&2
  exit 1
fi

# Guard: template repo must exist
if [ ! -d "$TEMPLATE_DIR/.git" ]; then
  echo -e "${RED}✗ Template repo not found: $TEMPLATE_DIR${NC}" >&2
  echo "Set TEMPLATE_DIR or create the repo first." >&2
  exit 1
fi

echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}  Forge Deploy Pipeline${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"

# Step 1: Push forge (skip if --skip-push or called from hook)
if [ "$SKIP_PUSH" = false ]; then
  echo -e "${CYAN}[1/3] Pushing forge...${NC}"
  if git -C "$PROJECT_DIR" push 2>&1; then
    echo -e "${GREEN}✓ Forge pushed${NC}"
  else
    echo -e "${RED}✗ Forge push failed${NC}" >&2
    exit 1
  fi
else
  echo -e "${YELLOW}[1/3] Skipping forge push (--skip-push)${NC}"
fi

# Step 2: Build template
echo -e "${CYAN}[2/3] Building template...${NC}"
if bash "$PROJECT_DIR/scripts/build-template.sh" "$TEMPLATE_DIR" 2>&1; then
  echo -e "${GREEN}✓ Template built${NC}"
else
  echo -e "${RED}✗ Template build failed${NC}" >&2
  exit 1
fi

# Step 3: Commit + push template
echo -e "${CYAN}[3/3] Committing and pushing template...${NC}"
cd "$TEMPLATE_DIR"

if [ -z "$(git status --porcelain)" ]; then
  echo -e "${YELLOW}! No changes in template repo — already up to date${NC}"
  exit 0
fi

FORGE_HASH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")
FILE_COUNT=$(git status --porcelain | wc -l | tr -d ' ')

git add -A
git commit -m "chore: template update from harness-forge ($FORGE_HASH)"

if git push 2>&1; then
  echo -e "${GREEN}✓ Template pushed ($FILE_COUNT files updated)${NC}"
else
  echo -e "${RED}✗ Template push failed${NC}" >&2
  exit 1
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  Deploy complete (forge $FORGE_HASH)${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
