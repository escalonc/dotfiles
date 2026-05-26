#!/usr/bin/env bash

section "»  Package Managers & Build Tools"

# ── pnpm globals ─────────────────────────────────────────────────────────────
if ! command -v pnpm &>/dev/null; then
  error "pnpm not on PATH — skipping global JS tooling (check Brewfile)"
else
  # `pnpm setup` configures PNPM_HOME and ensures the global bin dir is on PATH
  # for future shells. Without this, `pnpm add -g` installs binaries that aren't
  # invocable. Safe to run repeatedly.
  if [[ -z "${PNPM_HOME:-}" ]]; then
    info "Running pnpm setup..."
    pnpm setup >/dev/null 2>&1 || true
    # Use the location pnpm setup wrote for the remainder of this script.
    export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
    export PATH="$PNPM_HOME:$PATH"
  fi

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
