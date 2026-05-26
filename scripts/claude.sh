#!/usr/bin/env bash

section "»  Claude Code"

# Refresh command lookup cache so newly-installed binaries are visible.
have_claude() {
  hash -r 2>/dev/null
  command -v claude &>/dev/null || [ -x "$HOME/.local/bin/claude" ]
}

if have_claude; then
  success "Claude Code already installed ($(claude --version 2>/dev/null || echo 'installed'))"
else
  installed=0

  info "Installing Claude Code via native installer..."
  if curl -fsSL https://claude.ai/install.sh | bash && have_claude; then
    success "Claude Code installed (native)"
    installed=1
  fi

  if [[ $installed -eq 0 ]] && command -v pnpm &>/dev/null; then
    info "Native installer didn't land — trying pnpm..."
    if pnpm add -g @anthropic-ai/claude-code && have_claude; then
      success "Claude Code installed (pnpm)"
      installed=1
    fi
  fi

  if [[ $installed -eq 0 ]] && command -v npm &>/dev/null; then
    info "Falling back to npm..."
    if npm install -g @anthropic-ai/claude-code && have_claude; then
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
