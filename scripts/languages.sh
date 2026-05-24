#!/usr/bin/env bash

section "»  Languages & Runtimes"

# Node.js via fnm
eval "$(fnm env)"
if fnm list 2>/dev/null | grep -qE 'v[0-9]+\.[0-9]+\.[0-9]+'; then
  success "Node.js already installed via fnm ($(fnm current 2>/dev/null || echo 'unknown'))"
else
  info "Installing Node.js LTS via fnm..."
  fnm install --lts
  fnm use lts-latest
  fnm default lts-latest
  success "Node.js LTS"
fi

# Python via uv
if command -v uv &>/dev/null; then
  success "uv already installed ($(uv --version))"
else
  info "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  source "$HOME/.local/bin/env" 2>/dev/null || export PATH="$HOME/.local/bin:$PATH"
  success "uv — $(uv --version)"
fi

if uv python list --only-installed 2>/dev/null | grep -q .; then
  success "Python already installed via uv ($(uv python find 2>/dev/null | xargs -I{} basename {} || echo 'unknown'))"
else
  info "Installing latest Python via uv..."
  uv python install 2>>"$LOG_FILE" && success "Python installed via uv" || error "Python install failed"
fi

# Rust
if command -v rustup &>/dev/null; then
  success "Rust already installed"
else
  info "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --quiet
  source "$HOME/.cargo/env"
  success "Rust"
fi
