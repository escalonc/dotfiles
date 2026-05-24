#!/usr/bin/env bash

section "»  Package Managers & Build Tools"

PNPM_GLOBALS=(
  "typescript"
  "tsx"
  "vercel"
)

for pkg in "${PNPM_GLOBALS[@]}"; do
  info "Installing pnpm global: $pkg..."
  pnpm add -g "$pkg" 2>>"$LOG_FILE" && success "$pkg" || warn "Failed: $pkg (see $LOG_FILE)"
done

UV_TOOLS=(
  "ruff"
  "mypy"
  "httpx"
  "rich"
  "ipython"
)

for tool in "${UV_TOOLS[@]}"; do
  info "Installing uv tool: $tool..."
  uv tool install "$tool" 2>>"$LOG_FILE" && success "$tool" || warn "Failed: $tool (see $LOG_FILE)"
done
