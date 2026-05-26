#!/usr/bin/env bash

section "»  Languages & Runtimes"

# ── Node.js via fnm ──────────────────────────────────────────────────────────
if ! command -v fnm &>/dev/null; then
  error "fnm not on PATH — skipping Node install (check Brewfile)"
else
  eval "$(fnm env)"
  if fnm list 2>/dev/null | grep -q 'lts-latest'; then
    success "Node.js LTS already installed ($(fnm current 2>/dev/null || echo 'unknown'))"
  else
    info "Installing Node.js LTS via fnm..."
    if fnm install --lts && fnm default lts-latest; then
      fnm use lts-latest >/dev/null 2>&1 || true
      success "Node.js LTS"
    else
      error "Node.js LTS install failed"
    fi
  fi
fi

# ── Python via uv ────────────────────────────────────────────────────────────
if command -v uv &>/dev/null; then
  success "uv already installed ($(uv --version))"
else
  info "Installing uv..."
  if curl -LsSf https://astral.sh/uv/install.sh | sh; then
    # Make uv available for the rest of this script
    [[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
    export PATH="$HOME/.local/bin:$PATH"
    success "uv — $(uv --version 2>/dev/null || echo 'installed')"
  else
    error "uv install failed"
  fi
fi

if command -v uv &>/dev/null; then
  if uv python list --only-installed 2>/dev/null | grep -q .; then
    success "Python already installed via uv"
  else
    info "Installing latest Python via uv..."
    uv python install && success "Python installed via uv" || error "Python install failed"
  fi
fi

# ── Rust ─────────────────────────────────────────────────────────────────────
if command -v rustup &>/dev/null; then
  success "Rust already installed"
else
  info "Installing Rust via rustup..."
  if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --quiet; then
    [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
    success "Rust"
  else
    error "Rust install failed"
  fi
fi
