#!/usr/bin/env bash

section "»  Package Managers & Build Tools"

# ── pnpm globals ─────────────────────────────────────────────────────────────
if ! command -v pnpm &>/dev/null; then
  error "pnpm not on PATH — skipping global JS tooling (check Brewfile)"
else
  # We don't call `pnpm setup` because it edits ~/.zshrc, and setup.sh later
  # replaces ~/.zshrc with a symlink to dotfiles/.zshrc — wiping the edits.
  # Instead, dotfiles/.zshrc owns PNPM_HOME + PATH for future shells, and we
  # export the same values here so this setup process can use the globals too.
  export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
  mkdir -p "$PNPM_HOME"
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac

  PNPM_GLOBALS=(
    "typescript"
    "tsx"
    "vercel"
  )

  for pkg in "${PNPM_GLOBALS[@]}"; do
    info "Installing pnpm global: $pkg..."
    pnpm add -g "$pkg" && success "$pkg" || error "pnpm add -g $pkg failed"
  done
fi

# ── uv tools ─────────────────────────────────────────────────────────────────
if ! command -v uv &>/dev/null; then
  error "uv not on PATH — skipping Python tooling"
else
  UV_TOOLS=(
    "ruff"
    "mypy"
    "httpx"
    "rich"
    "ipython"
  )

  for tool in "${UV_TOOLS[@]}"; do
    info "Installing uv tool: $tool..."
    uv tool install "$tool" && success "$tool" || error "uv tool install $tool failed"
  done
fi
