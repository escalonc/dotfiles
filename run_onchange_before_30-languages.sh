#!/usr/bin/env bash
set -euo pipefail

# Node via fnm. fnm itself is installed via the Brewfile.
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
