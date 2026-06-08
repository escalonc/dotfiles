#!/usr/bin/env bash
set -euo pipefail

# fnm provides Node — from the Brewfile on macOS, from ~/.local/bin on Linux
# (10-packages). Ensure that dir is on PATH so we can find it during this run.
export PATH="$HOME/.local/bin:$PATH"

# Node via fnm.
if command -v fnm &>/dev/null; then
  eval "$(fnm env)"
  # fnm aliases a freshly-installed LTS as `lts-latest`; check for a default alias.
  if ! NO_COLOR=1 fnm alias 2>/dev/null | grep -q 'default'; then
    echo "→ Installing Node.js LTS via fnm..."
    fnm install --lts
    fnm default lts-latest
    echo "✓ Node.js LTS — set as default"
  fi
fi
