#!/usr/bin/env bash
set -euo pipefail

# pnpm globals. The pnpm binary comes from the Brewfile (macOS) or the standalone
# installer into PNPM_HOME (Linux, 10-packages). Set PNPM_HOME + PATH FIRST so
# `command -v pnpm` finds a freshly-installed pnpm that isn't on PATH yet.
case "$(uname -s)" in
  Darwin) export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}" ;;
  *)      export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}" ;;
esac
mkdir -p "$PNPM_HOME"
export PATH="$HOME/.local/bin:$PNPM_HOME:$PATH"

if command -v pnpm &>/dev/null; then
  for pkg in typescript tsx vercel; do
    echo "→ pnpm global: $pkg"
    pnpm add -g "$pkg" || echo "! skipped: $pkg" >&2
  done
fi
