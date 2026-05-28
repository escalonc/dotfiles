#!/usr/bin/env bash
set -euo pipefail

# Node via fnm. fnm itself is installed via the Brewfile.
if command -v fnm &>/dev/null; then
  eval "$(fnm env)"
  if ! NO_COLOR=1 fnm list 2>/dev/null | grep -q 'default'; then
    echo "→ Installing Node.js LTS via fnm..."
    fnm install --lts
    lts_ver=$(NO_COLOR=1 fnm list 2>/dev/null \
      | grep -i 'lts' \
      | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' \
      | sort -V | tail -1)
    if [ -n "$lts_ver" ]; then
      fnm default "$lts_ver"
      echo "✓ Node.js LTS ($lts_ver) — set as default"
    else
      echo "! Node.js LTS installed but couldn't identify version to set as default" >&2
    fi
  fi
fi

# Python via uv. uv is installed standalone (not in Brewfile).
if ! command -v uv &>/dev/null; then
  echo "→ Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  [ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
  export PATH="$HOME/.local/bin:$PATH"
fi
if command -v uv &>/dev/null; then
  if ! uv python list --only-installed 2>/dev/null | grep -q .; then
    echo "→ Installing latest Python via uv..."
    uv python install
  fi
fi

# Rust via rustup. Standalone install.
if ! command -v rustup &>/dev/null; then
  echo "→ Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --quiet
fi
