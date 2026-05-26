#!/usr/bin/env bash

section "»  Languages & Runtimes"

# ── Node.js via fnm ──────────────────────────────────────────────────────────
if ! command -v fnm &>/dev/null; then
  error "fnm not on PATH — skipping Node install (check Brewfile)"
else
  eval "$(fnm env)"
  # Use `fnm current` as the idempotency check — works regardless of which
  # alias name a given fnm version uses for LTS (lts-latest, lts/iron, etc).
  NODE_CUR=$(fnm current 2>/dev/null || echo "none")
  if [ "$NODE_CUR" != "none" ] && [ "$NODE_CUR" != "system" ]; then
    success "Node.js already installed via fnm ($NODE_CUR)"
  else
    info "Installing Node.js LTS via fnm..."
    if fnm install --lts; then
      # Don't rely on `lts-latest` (alias name varies by fnm version);
      # default to whatever version is now current.
      installed_ver=$(fnm current 2>/dev/null)
      if [ -z "$installed_ver" ] || [ "$installed_ver" = "none" ]; then
        # Fall back to picking the newest installed version
        installed_ver=$(fnm list 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1)
      fi
      if [ -n "$installed_ver" ] && fnm default "$installed_ver"; then
        success "Node.js LTS ($installed_ver)"
      else
        warn "Node.js installed but default not set"
      fi
    else
      error "fnm install --lts failed"
    fi
  fi
fi

# ── Python via uv ────────────────────────────────────────────────────────────
if command -v uv &>/dev/null; then
  success "uv already installed ($(uv --version))"
else
  info "Installing uv..."
  if curl -LsSf https://astral.sh/uv/install.sh | sh; then
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
    if [[ -f "$HOME/.cargo/env" ]]; then
      source "$HOME/.cargo/env"
      success "Rust"
    else
      # Installer claimed success but didn't leave the env script behind.
      warn "Rust installed but $HOME/.cargo/env missing — restart your shell"
    fi
  else
    error "Rust install failed"
  fi
fi
