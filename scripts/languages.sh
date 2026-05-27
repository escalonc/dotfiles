#!/usr/bin/env bash

section "»  Languages & Runtimes"

# ── Node.js via fnm ──────────────────────────────────────────────────────────
if ! command -v fnm &>/dev/null; then
  error "fnm not on PATH — skipping Node install (check Brewfile)"
else
  eval "$(fnm env)"
  # Idempotency: the real goal is "a default Node is set" — just having a
  # version installed isn't enough, because future shells need a default to
  # resolve `node`. `fnm list` marks the default line with the word "default".
  if NO_COLOR=1 fnm list 2>/dev/null | grep -q 'default'; then
    success "Node.js already configured via fnm ($(fnm current 2>/dev/null || echo 'default set'))"
  else
    info "Installing Node.js LTS via fnm..."
    if fnm install --lts; then
      # Identify the installed LTS version from the LTS-tagged lines only.
      # If we can't find one, fail closed (warn, no default) rather than
      # defaulting to an arbitrary non-LTS version that might be installed.
      lts_ver=$(NO_COLOR=1 fnm list 2>/dev/null | grep -i 'lts' | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1)
      if [ -z "$lts_ver" ]; then
        warn "Node.js LTS installed but couldn't identify the version to set as default — run 'fnm default <version>' manually"
      elif fnm default "$lts_ver"; then
        success "Node.js LTS ($lts_ver)"
      else
        warn "Node.js LTS installed but 'fnm default $lts_ver' failed"
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
