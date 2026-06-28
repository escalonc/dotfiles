#!/bin/sh
# Bootstrap a fresh machine: install Homebrew (Xcode CLT + git) or git on Linux, then chezmoi clone + apply.
# Run: sh -c "$(curl -fsSL https://raw.githubusercontent.com/escalonc/dotfiles/main/install.sh)"
set -eu

# ── Banner (sunset gradient: yellow → orange → red) ──────────────────────────
printf '\n\033[1;38;5;220m'
cat <<'EOF'
██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
EOF
printf '\033[1;38;5;208m'
cat <<'EOF'
██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
EOF
printf '\033[1;38;5;196m'
cat <<'EOF'
██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
EOF
printf '\033[0m\033[2m        escalonc · zero → a fully-provisioned machine\033[0m\n\n'

case "$(uname -s)" in
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      # NONINTERACTIVE needs pre-authorized sudo; keep the timestamp warm through the slow install.
      echo "→ Authorizing sudo (you'll be prompted for your password once)..."
      sudo -v
      while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
      keepalive_pid=$!
      trap 'kill "$keepalive_pid" 2>/dev/null || true' EXIT

      echo "→ Installing Homebrew (also installs the Xcode Command Line Tools + git headlessly)..."
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # Put brew on PATH for the chezmoi handoff below (this is its own process).
    eval "$(/opt/homebrew/bin/brew shellenv)"
    ;;
  Linux)
    # A fresh box may lack git (chezmoi needs it to clone); full toolchain comes later via run_onchange.
    if ! command -v git >/dev/null 2>&1; then
      echo "→ Installing git + curl via dnf..."
      sudo dnf install -y git curl
    fi
    ;;
esac

echo "→ Handing off to chezmoi (clone + apply)..."
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply escalonc
