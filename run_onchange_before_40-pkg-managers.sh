#!/usr/bin/env bash
set -euo pipefail

# pnpm globals. pnpm comes from the Brewfile; dot_zshrc owns PNPM_HOME + PATH
# for future shells. We export the same values here so this script can install
# globals into the right bin dir.
if command -v pnpm &>/dev/null; then
  export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
  mkdir -p "$PNPM_HOME"
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac

  for pkg in typescript tsx vercel; do
    echo "→ pnpm global: $pkg"
    pnpm add -g "$pkg"
  done
fi

# uv tools.
if command -v uv &>/dev/null; then
  for tool in ruff mypy httpx rich ipython; do
    echo "→ uv tool: $tool"
    uv tool install "$tool"
  done
fi
