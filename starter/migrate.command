#!/bin/bash
# Mac launcher for Own Your Site.
# Double-click this file in Finder. It opens Terminal in this folder
# and starts Claude Code automatically.

cd "$(dirname "$0")"

if ! command -v claude &> /dev/null; then
  echo "Claude Code is not installed yet."
  echo "Open https://claude.com/claude-code in your browser and follow the install instructions."
  echo "Then double-click this file again."
  read -p "Press Enter to close..."
  exit 1
fi

claude
