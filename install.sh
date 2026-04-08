#!/bin/sh
# Claude Blueprint Installer
# Installs .claude/commands/ into the current directory
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/jake-ritz11/claude-blueprint/main/install.sh | sh

set -e

REPO="jake-ritz11/claude-blueprint"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

COMMANDS_DIR=".claude/commands"

# Colors (if terminal supports them)
if [ -t 1 ]; then
  BOLD="\033[1m"
  GREEN="\033[32m"
  YELLOW="\033[33m"
  RESET="\033[0m"
else
  BOLD=""
  GREEN=""
  YELLOW=""
  RESET=""
fi

info() {
  printf "${GREEN}%s${RESET}\n" "$1"
}

warn() {
  printf "${YELLOW}%s${RESET}\n" "$1"
}

# Check for curl
if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required but not installed."
  exit 1
fi

# Check if .claude/commands/ already exists
if [ -d "$COMMANDS_DIR" ]; then
  warn "Warning: $COMMANDS_DIR already exists."
  printf "Overwrite existing commands? [y/N] "
  read -r answer
  case "$answer" in
    [yY]|[yY][eE][sS]) ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

# Create directory
mkdir -p "$COMMANDS_DIR"

# Command files to download
FILES="
_plans-config.md
blueprint.md
research.md
plan.md
execute-plan.md
iterate-plan.md
validate-plan.md
"

echo ""
info "Installing Claude Blueprint commands..."
echo ""

# Download each file
for file in $FILES; do
  printf "  Downloading %s..." "$file"
  if curl -sfL "${BASE_URL}/.claude/commands/${file}" -o "${COMMANDS_DIR}/${file}"; then
    printf " done\n"
  else
    printf " FAILED\n"
    echo "Error: Failed to download ${file}"
    exit 1
  fi
done

echo ""
info "Claude Blueprint installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Customize ${BOLD}.claude/commands/_plans-config.md${RESET} with your project's standards files"
echo "  2. Run ${BOLD}/blueprint${RESET} in Claude Code to start"
echo ""
echo "See examples at: https://github.com/${REPO}/tree/${BRANCH}/examples"
