#!/usr/bin/env bash
set -euo pipefail

ZSH_DIR="$HOME/.oh-my-zsh"

if [ ! -d "$ZSH_DIR" ]; then
  echo "→ Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="$ZSH_DIR/custom"

clone_if_missing() {
  local url=$1 dir=$2
  if [ ! -d "$dir" ]; then
    echo "→ Cloning $(basename "$dir")..."
    git clone --depth=1 "$url" "$dir" --quiet
  fi
}

clone_if_missing https://github.com/romkatv/powerlevel10k.git         "$ZSH_CUSTOM/themes/powerlevel10k"
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions     "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_if_missing https://github.com/zsh-users/zsh-completions         "$ZSH_CUSTOM/plugins/zsh-completions"
