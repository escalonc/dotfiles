#!/usr/bin/env bash

section "»  Claude Code"

if command -v claude &>/dev/null; then
  success "Claude Code already installed ($(claude --version 2>/dev/null || echo 'unknown version'))"
else
  installed=0

  info "Installing Claude Code via native installer..."
  if curl -fsSL https://claude.ai/install.sh | bash; then
    success "Claude Code installed (native)"
    installed=1
  fi

  if [[ $installed -eq 0 ]] && command -v pnpm &>/dev/null; then
    info "Native installer failed, trying pnpm..."
    if pnpm add -g @anthropic-ai/claude-code; then
      success "Claude Code installed (pnpm)"
      installed=1
    fi
  fi

  if [[ $installed -eq 0 ]] && command -v npm &>/dev/null; then
    info "Falling back to npm..."
    if npm install -g @anthropic-ai/claude-code; then
      success "Claude Code installed (npm)"
      installed=1
    fi
  fi

  [[ $installed -eq 0 ]] && error "Claude Code installation failed via all methods"
fi

if command -v code &>/dev/null; then
  info "Installing Claude Code VS Code extension..."
  code --install-extension anthropic.claude-code --force &>/dev/null \
    && success "Claude Code VS Code extension" \
    || warn "Claude Code VS Code extension install skipped"
fi
