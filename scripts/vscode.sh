#!/usr/bin/env bash

section "»  VS Code Extensions"

VSCODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
[[ -d "$VSCODE_BIN" ]] && export PATH="$VSCODE_BIN:$PATH"

if ! command -v code &>/dev/null; then
  warn "VS Code CLI not found, skipping extensions (launch VS Code once first)"
  return 0
fi

EXTENSIONS=(
  "esbenp.prettier-vscode"
  "dbaeumer.vscode-eslint"
  "eamodio.gitlens"
  "mhutchie.git-graph"
  "github.copilot"
  "github.copilot-chat"
  "bradlc.vscode-tailwindcss"
  "ms-vscode.vscode-typescript-next"
  "prisma.prisma"
  "ms-python.python"
  "charliermarsh.ruff"
  "ms-python.mypy-type-checker"
  "rust-lang.rust-analyzer"
  "tamasfe.even-better-toml"
  "ms-vscode-remote.remote-ssh"
  "ms-vscode-remote.remote-containers"
  "ms-azuretools.vscode-docker"
  "redhat.vscode-yaml"
  "yzhang.markdown-all-in-one"
  "gruntfuggly.todo-tree"
  "streetsidesoftware.code-spell-checker"
  "usernamehw.errorlens"
  "formulahendry.auto-rename-tag"
  "christian-kohler.path-intellisense"
  "mikestead.dotenv"
  "yoavbls.pretty-ts-errors"
)

for ext in "${EXTENSIONS[@]}"; do
  code --install-extension "$ext" --force &>/dev/null && success "$ext" || warn "Skipped: $ext"
done
