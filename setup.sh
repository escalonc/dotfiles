#!/usr/bin/env bash
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Logging ─────────────────────────────────────────────────────────────────
LOG_FILE="$HOME/dev-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "━━━ Setup started at $(date) ━━━"

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

# ─── Helpers ─────────────────────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/helpers.sh"

# ─── Banner ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗${RESET}"
echo -e "${BOLD}${CYAN}  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝${RESET}"
echo -e "${BOLD}${CYAN}  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗${RESET}"
echo -e "${BOLD}${CYAN}  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║${RESET}"
echo -e "${BOLD}${CYAN}  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║${RESET}"
echo -e "${BOLD}${CYAN}  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝${RESET}"
echo ""
echo -e "  ${DIM}macOS developer environment — dotfiles + tools + preferences${RESET}"
echo -e "  ${DIM}Estimated time: 20-40 minutes depending on your internet speed.${RESET}"
echo ""
echo -e "  ${WARN}  ${YELLOW}sudo access is required. You may be prompted for your password.${RESET}"
echo ""
read -rp "  Press ENTER to begin or Ctrl+C to cancel..."

# ─── Sudo keepalive ──────────────────────────────────────────────────────────
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ─── Homebrew ────────────────────────────────────────────────────────────────
section "»  Homebrew"

if command -v brew &>/dev/null; then
  success "Homebrew already installed"
  info "Updating Homebrew..."
  brew update --quiet 2>>"$LOG_FILE" || warn "brew update failed — proceeding with cached formulae"
else
  info "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ "$(uname -m)" == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  success "Homebrew installed"
fi

brew analytics off

# ─── Brew Bundle ─────────────────────────────────────────────────────────────
section "»  Installing Formulae & Casks (Brewfile)"

info "Running brew bundle..."
if brew bundle --file="$DOTFILES_DIR/Brewfile" 2>>"$LOG_FILE"; then
  success "Brewfile installed"
else
  warn "Some Brewfile entries failed (see $LOG_FILE)"
fi

# ─── Shell ───────────────────────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/shell.sh"

# ─── Languages ───────────────────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/languages.sh"

# ─── Packages ────────────────────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/packages.sh"

# ─── VS Code ────────────────────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/vscode.sh"

# ─── Git ─────────────────────────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/git.sh"

# ─── SSH (1Password Agent) ───────────────────────────────────────────────────
section "»  SSH — 1Password Agent"

mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/config" ] || ! grep -q "1password" "$HOME/.ssh/config"; then
  cp "$DOTFILES_DIR/dotfiles/.ssh/config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
  success "SSH config linked"
else
  success "1Password SSH agent already configured"
fi

echo ""
warn "Manual steps required after install:"
info "1. Open 1Password → Settings → Developer → enable 'Use the SSH agent'"
info "2. Create or import your SSH keys inside 1Password (New Item → SSH Key)"
info "3. Copy the public key from 1Password → add to GitHub/GitLab"
info "4. Test with: ssh -T git@github.com"
echo ""

# ─── Link Dotfiles ───────────────────────────────────────────────────────────
section "»  Linking Dotfiles"

link_dotfile() {
  local src="$1" dst="$2"
  if [ -f "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
    info "Backed up existing $(basename "$dst")"
  fi
  ln -sf "$src" "$dst"
  success "$(basename "$dst") → $src"
}

link_dotfile "$DOTFILES_DIR/dotfiles/.zshrc" "$HOME/.zshrc"
link_dotfile "$DOTFILES_DIR/dotfiles/.gitignore_global" "$HOME/.gitignore_global"

# ─── macOS Defaults ──────────────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/macos.sh"

# ─── Claude Code ─────────────────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/claude.sh"

# ─── Cleanup ─────────────────────────────────────────────────────────────────
section "»  Cleanup"

info "Running brew cleanup..."
brew cleanup --quiet 2>>"$LOG_FILE" || warn "brew cleanup had issues (see $LOG_FILE)"
brew autoremove --quiet 2>>"$LOG_FILE" || warn "brew autoremove had issues (see $LOG_FILE)"

# ─── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "━━━ Setup finished at $(date) ━━━" >> "$LOG_FILE"

if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo ""
  echo -e "${BOLD}${YELLOW}  ⚠  ${#FAILED_STEPS[@]} step(s) had issues:${RESET}"
  for step in "${FAILED_STEPS[@]}"; do
    echo -e "     ${RED}•${RESET} $step"
  done
  echo -e "  ${DIM}Full details in: $LOG_FILE${RESET}"
else
  echo -e "${BOLD}${GREEN}  ✔  All steps completed successfully!${RESET}"
fi

echo ""
echo -e "${BOLD}${GREEN}  ╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${GREEN}  ║      Setup Complete! Your Mac is ready for development.      ║${RESET}"
echo -e "${BOLD}${GREEN}  ╚══════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${BOLD}Next steps:${RESET}"
echo ""
echo -e "  ${CYAN} 1.${RESET} Restart your terminal (or run: ${BOLD}source ~/.zshrc${RESET})"
echo -e "  ${CYAN} 2.${RESET} Run ${BOLD}p10k configure${RESET} to set up your prompt"
echo -e "  ${CYAN} 3.${RESET} Open ${BOLD}1Password${RESET} → Settings → Developer → enable SSH agent"
echo -e "  ${CYAN} 4.${RESET} Create your SSH key in ${BOLD}1Password${RESET} → add public key to GitHub/GitLab"
echo -e "  ${CYAN} 5.${RESET} Run ${BOLD}gh auth login${RESET} to authenticate the GitHub CLI"
echo -e "  ${CYAN} 6.${RESET} Run ${BOLD}claude${RESET} in your terminal to authenticate Claude Code"
echo -e "  ${CYAN} 7.${RESET} Open ${BOLD}OrbStack${RESET} and complete setup"
echo -e "  ${CYAN} 8.${RESET} Open ${BOLD}Raycast${RESET} and configure your extensions"
echo -e "  ${CYAN} 9.${RESET} Set ${BOLD}JetBrainsMono Nerd Font${RESET} in your terminal"
echo -e "  ${CYAN}10.${RESET} Run ${BOLD}atuin import auto${RESET} to import existing shell history"
echo -e "  ${CYAN}11.${RESET} Sign in to ${BOLD}CleanShot X${RESET} with your license"
echo -e "  ${CYAN}12.${RESET} Open ${BOLD}System Settings → Displays${RESET} → uncheck ${BOLD}True Tone${RESET}"
echo -e "  ${CYAN}13.${RESET} Restart your Mac to apply all system changes"
echo ""
echo -e "  ${DIM}Full log saved to: $LOG_FILE${RESET}"
echo ""
