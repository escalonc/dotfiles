#!/usr/bin/env bash

section "»  Claude Code"

if command -v claude &>/dev/null; then
  success "Claude Code already installed ($(claude --version 2>/dev/null || echo 'unknown version'))"
else
  info "Installing Claude Code via native installer..."
  if curl -fsSL https://claude.ai/install.sh | bash; then
    success "Claude Code installed"
  else
    warn "Native installer failed, falling back to pnpm..."
    if pnpm add -g @anthropic-ai/claude-code 2>>"$LOG_FILE"; then
      success "Claude Code installed via pnpm"
    else
      error "Claude Code installation failed"
    fi
  fi
fi

if command -v code &>/dev/null; then
  info "Installing Claude Code VS Code extension..."
  code --install-extension anthropic.claude-code --force &>/dev/null \
    && success "Claude Code VS Code extension" \
    || warn "Claude Code VS Code extension install skipped"
fi
