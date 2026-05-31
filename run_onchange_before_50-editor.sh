#!/usr/bin/env bash
set -euo pipefail

# Add the macOS VS Code app's `code` CLI to PATH if present. On Linux,
# `code` is a regular binary so this no-ops.
VSCODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
[ -d "$VSCODE_BIN" ] && export PATH="$VSCODE_BIN:$PATH"

if ! command -v code &>/dev/null; then
  echo "! VS Code CLI not found — skipping extensions (launch VS Code once first)" >&2
  exit 0
fi

EXTENSIONS=(
  esbenp.prettier-vscode
  dbaeumer.vscode-eslint
  eamodio.gitlens
  mhutchie.git-graph
  github.copilot
  github.copilot-chat
  bradlc.vscode-tailwindcss
  ms-vscode.vscode-typescript-next
  prisma.prisma
  ms-python.python
  charliermarsh.ruff
  ms-python.mypy-type-checker
  rust-lang.rust-analyzer
  tamasfe.even-better-toml
  ms-vscode-remote.remote-ssh
  ms-vscode-remote.remote-containers
  ms-azuretools.vscode-docker
  redhat.vscode-yaml
  yzhang.markdown-all-in-one
  gruntfuggly.todo-tree
  streetsidesoftware.code-spell-checker
  usernamehw.errorlens
  formulahendry.auto-rename-tag
  christian-kohler.path-intellisense
  mikestead.dotenv
  yoavbls.pretty-ts-errors
)

for ext in "${EXTENSIONS[@]}"; do
  if code --install-extension "$ext" --force &>/dev/null; then
    echo "✓ $ext"
  else
    echo "! skipped: $ext"
  fi
done
