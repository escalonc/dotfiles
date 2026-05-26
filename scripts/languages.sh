#!/usr/bin/env bash

section "»  Languages & Runtimes"

# ── Node.js via fnm ──────────────────────────────────────────────────────────
if ! command -v fnm &>/dev/null; then
  error "fnm not on PATH — skipping Node install (check Brewfile)"
else
  eval "$(fnm env)"
  # Idempotency: any installed version satisfies "fnm is set up". `fnm current`
  # returns "none" when nothing is active even if a version is installed, so
  # we check `fnm list` for any version line.
  if fnm list 2>/dev/null | grep -qE 'v[0-9]+'; then
    success "Node.js already installed via fnm ($(fnm current 2>/dev/null || echo 'installed'))"
  else
    info "Installing Node.js LTS via fnm..."
    if fnm install --lts; then
      # `fnm install --lts` prints the version it installed; recapture it from
      # `fnm list` filtering for LTS lines specifically, then default to that.
      # This avoids picking a non-LTS version if one was somehow installed first.
      installed_ver=$(NO_COLOR=1 fnm list 2>/dev/null | grep -i 'lts' | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1)
      [ -z "$installed_ver" ] && installed_ver=$(NO_COLOR=1 fnm list 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1)
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
