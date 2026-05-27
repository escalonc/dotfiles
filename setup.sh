#!/usr/bin/env bash
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Logging ─────────────────────────────────────────────────────────────────
LOG_FILE="$HOME/dev-setup.log"
# Only install our own tee if bootstrap.sh isn't already tee'ing — otherwise
# every line ends up in the log twice and writers race on the same file.
if [ -z "${_DEV_SETUP_LOGGING:-}" ]; then
  export _DEV_SETUP_LOGGING=1
  exec > >(tee -a "$LOG_FILE") 2>&1
fi
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
# `read -rp` writes its prompt to stderr, which is now piped through tee —
# pipe buffering can swallow the prompt. Print it explicitly first so the user
# always sees it, then read from /dev/tty if a tty is available (skips in CI / nohup / non-tty SSH).
echo -en "  ${BOLD}Press ENTER to begin or Ctrl+C to cancel...${RESET}"
if [ -t 0 ] || [ -r /dev/tty ]; then
  read -r _ </dev/tty || true
fi
echo ""

# ─── Sudo keepalive ──────────────────────────────────────────────────────────
# Keep sudo timestamp refreshed so long-running brew/macos steps don't prompt mid-run.
# Only spawn the keepalive after `sudo -v` succeeds — otherwise the loop would
# spam `sudo -n true` failures every 60s with no working ticket.
if sudo -v; then
  # The loop self-terminates when the parent shell dies (kill -0 "$$"), so even
  # if a Ctrl-C lands in the tiny window before SUDO_KEEPALIVE_PID is assigned,
  # the loop still exits within ~60s. We kill by PID (not `%1`) to avoid job-spec
  # ambiguity with the `exec > >(tee ...)` process substitution.
  ( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) &
  SUDO_KEEPALIVE_PID=$!
else
  warn "sudo unavailable — macOS defaults section will be skipped"
  SUDO_OK=false
fi
cleanup() { [ -n "${SUDO_KEEPALIVE_PID:-}" ] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true; }
# EXIT cleans up on normal exit; INT/TERM clean up AND exit with the conventional
# 128+signal code so Ctrl-C during a foreground step (e.g. brew bundle) stops the
# whole script instead of letting it continue.
trap 'cleanup' EXIT
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# ─── Homebrew ────────────────────────────────────────────────────────────────
section "»  Homebrew"

BREW_PREFIX="/usr/local"
[[ "$(uname -m)" == "arm64" ]] && BREW_PREFIX="/opt/homebrew"

if command -v brew &>/dev/null; then
  success "Homebrew already installed"
  info "Updating Homebrew..."
  brew update --quiet || warn "brew update failed — proceeding with cached formulae"
else
  info "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  success "Homebrew installed"
fi

# Always ensure brew shellenv is loaded for this shell AND persisted to .zprofile
# (covers the case where bootstrap installed brew but setup.sh sees it as already there).
eval "$($BREW_PREFIX/bin/brew shellenv)"
touch "$HOME/.zprofile"
# Match only active (uncommented) shellenv lines so a deliberately
# commented-out one doesn't block re-adding the active version.
grep -qE '^[[:space:]]*eval.*brew shellenv' "$HOME/.zprofile" || \
  echo "eval \"\$($BREW_PREFIX/bin/brew shellenv)\"" >> "$HOME/.zprofile"

brew analytics off

# ─── Brew Bundle ─────────────────────────────────────────────────────────────
section "»  Installing Formulae & Casks (Brewfile)"

info "Running brew bundle..."
# Capture brew bundle's own output so we can surface the actual error when
# `bundle check` doesn't match (e.g., tap fetch failure rather than missing pkg).
# Fall back to /dev/null if mktemp fails so we never `tee` to an empty path.
BUNDLE_LOG=$(mktemp 2>/dev/null) || BUNDLE_LOG=/dev/null
# Run the pipeline, then capture brew's exit (PIPESTATUS[0]) into a var
# immediately — clearer than chaining `&& [ PIPESTATUS ]`, and pipefail alone
# would already mask which side failed.
brew bundle --file="$DOTFILES_DIR/Brewfile" 2>&1 | tee "$BUNDLE_LOG"
bundle_status=${PIPESTATUS[0]}
if [ "$bundle_status" -eq 0 ]; then
  success "Brewfile installed"
else
  # `brew bundle check --verbose` prefixes each missing entry with an arrow,
  # e.g. "→ Cask 'foo' needs to be installed." Strip the prefix + suffix and
  # name each one in FAILED_STEPS so the summary points at real packages.
  missing_count=0
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    pkg=$(echo "$line" | sed -E 's/^[[:space:]]*[→>][[:space:]]*//; s/[[:space:]]*needs to be installed.*$//; s/^[[:space:]]*//')
    error "Brewfile entry failed: ${pkg:-$line}"
    missing_count=$((missing_count + 1))
  done < <(brew bundle check --file="$DOTFILES_DIR/Brewfile" --verbose 2>&1 | grep -E 'needs to be installed' || true)
  # Fallback: if `bundle check` matched nothing (network/tap error, etc.),
  # surface the actual brew bundle output so the user has something to debug.
  if [[ $missing_count -eq 0 ]]; then
    error "brew bundle failed; tail of output:"
    [ "$BUNDLE_LOG" != /dev/null ] && tail -10 "$BUNDLE_LOG" | sed 's/^/    /'
  fi
fi
[ "$BUNDLE_LOG" != /dev/null ] && rm -f "$BUNDLE_LOG"

# ─── Shell ───────────────────────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/shell.sh"

# ─── Languages ───────────────────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/languages.sh"

# ─── Packages ────────────────────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/packages.sh"

# ─── VS Code ────────────────────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/vscode.sh"

# ─── Git (config symlinked in the Linking Dotfiles section below) ─────────────

# ─── SSH (1Password Agent) ───────────────────────────────────────────────────
section "»  SSH — 1Password Agent"

mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
SSH_CONFIG="$HOME/.ssh/config"
# Use a specific marker (the agent socket path) so we don't false-positive on
# unrelated "1password" mentions in the user's config.
SSH_MARKER='2BUA8C4S2C.com.1password'

if [ -f "$SSH_CONFIG" ] && grep -qF "$SSH_MARKER" "$SSH_CONFIG"; then
  success "1Password SSH agent already configured"
elif [ ! -f "$SSH_CONFIG" ]; then
  cp "$DOTFILES_DIR/dotfiles/.ssh/config" "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"
  success "SSH config written"
else
  # Pre-existing config without our agent block. Back it up, then PREPEND our
  # block so OpenSSH's first-match-wins rule picks IdentityAgent from us even
  # when the user already has a `Host *` block of their own.
  cp "$SSH_CONFIG" "$SSH_CONFIG.backup.$(date +%Y%m%d%H%M%S)"
  info "Backed up existing ~/.ssh/config"
  tmp=$(mktemp)
  cat "$DOTFILES_DIR/dotfiles/.ssh/config" > "$tmp"
  # Ensure a blank line between our block and the existing content
  echo "" >> "$tmp"
  cat "$SSH_CONFIG" >> "$tmp"
  mv "$tmp" "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"
  success "Prepended 1Password block to existing SSH config"
  warn "Our 'Host *' block is now FIRST, and OpenSSH uses the first IdentityAgent"
  warn "it sees — so 1Password's agent now applies to ALL hosts, OVERRIDING any"
  warn "per-host IdentityAgent you had later in the file. If a host needs a"
  warn "different agent, move its block above ours or restore the .backup.* file."
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
  # Back up anything at $dst that isn't a symlink (file, dir, or other).
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
    info "Backed up existing $(basename "$dst")"
  fi
  # -n treats an existing symlink-to-directory as a regular file (BSD ln on
  # macOS otherwise creates dst/src inside the linked directory).
  ln -sfn "$src" "$dst"
  success "$(basename "$dst") → $src"
}

link_dotfile "$DOTFILES_DIR/dotfiles/.zshrc" "$HOME/.zshrc"
link_dotfile "$DOTFILES_DIR/dotfiles/.gitignore_global" "$HOME/.gitignore_global"
link_dotfile "$DOTFILES_DIR/dotfiles/.gitconfig" "$HOME/.gitconfig"

# ─── macOS Defaults ──────────────────────────────────────────────────────────
# macos.sh needs sudo for `defaults write /Library/Preferences/...`. Use the
# non-interactive `sudo -n -v` here: if the cached ticket is still valid (the
# keepalive kept it warm) it succeeds silently; if not, it fails fast and we
# skip the section rather than blocking on a password prompt in an unattended run.
if [ "${SUDO_OK:-true}" = "true" ] && sudo -n -v 2>/dev/null; then
  source "$DOTFILES_DIR/scripts/macos.sh"
else
  error "sudo unavailable — skipping macOS system defaults (run setup.sh again later)"
fi

# ─── Claude Code ─────────────────────────────────────────────────────────────
source "$DOTFILES_DIR/scripts/claude.sh"

# ─── Cleanup ─────────────────────────────────────────────────────────────────
section "»  Cleanup"

info "Running brew cleanup..."
brew cleanup --quiet || warn "brew cleanup had issues (see $LOG_FILE)"
brew autoremove --quiet || warn "brew autoremove had issues (see $LOG_FILE)"

# Keep only the 3 newest dotfile backups so they don't pile up across runs.
for base in "$HOME/.zshrc" "$HOME/.gitignore_global" "$HOME/.ssh/config" "$HOME/.gitconfig"; do
  ls -1t "$base".backup.* 2>/dev/null | tail -n +4 | xargs -I{} rm -f -- "{}" 2>/dev/null || true
done

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
