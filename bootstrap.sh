#!/usr/bin/env bash
# curl -fsSL https://raw.githubusercontent.com/escalonc/dotfiles/main/bootstrap.sh | bash
set -uo pipefail

DOTFILES_REPO="https://github.com/escalonc/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
LOG_FILE="$HOME/dev-setup.log"

# Capture all bootstrap output (including the Homebrew install) to the log
exec > >(tee -a "$LOG_FILE") 2>&1
echo "━━━ Bootstrap started at $(date) ━━━"

echo "Installing Xcode Command Line Tools + Homebrew..."
if ! command -v brew &>/dev/null; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Always ensure brew shellenv is on PATH for this shell AND in .zprofile for future login shells.
# We do this even when brew was pre-installed, so future logins don't lose /opt/homebrew/bin.
BREW_PREFIX="/usr/local"
[[ "$(uname -m)" == "arm64" ]] && BREW_PREFIX="/opt/homebrew"
SHELLENV_LINE="eval \"\$($BREW_PREFIX/bin/brew shellenv)\""

eval "$($BREW_PREFIX/bin/brew shellenv)"
touch "$HOME/.zprofile"
grep -qF "brew shellenv" "$HOME/.zprofile" || echo "$SHELLENV_LINE" >> "$HOME/.zprofile"

echo "Cloning dotfiles..."
if [ -d "$DOTFILES_DIR" ]; then
  echo "  ~/.dotfiles already exists, pulling latest..."
  # --autostash so local edits to symlinked dotfiles don't abort the pull.
  # If pull still fails (conflict, etc.), keep going with the existing tree.
  git -C "$DOTFILES_DIR" pull --rebase --autostash || \
    echo "  ! pull failed — continuing with existing local copy"
else
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

echo "Running setup..."
cd "$DOTFILES_DIR"
chmod +x setup.sh
./setup.sh
