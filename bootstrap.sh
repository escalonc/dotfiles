#!/usr/bin/env bash
# curl -fsSL https://raw.githubusercontent.com/escalonc/dotfiles/main/bootstrap.sh | bash
set -euo pipefail

DOTFILES_REPO="https://github.com/escalonc/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "Installing Xcode Command Line Tools + Homebrew..."
if ! command -v brew &>/dev/null; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ "$(uname -m)" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

echo "Cloning dotfiles..."
if [ -d "$DOTFILES_DIR" ]; then
  echo "  ~/.dotfiles already exists, pulling latest..."
  git -C "$DOTFILES_DIR" pull --rebase
else
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

echo "Running setup..."
cd "$DOTFILES_DIR"
chmod +x setup.sh
./setup.sh
