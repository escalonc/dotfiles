#!/bin/sh
# Bootstrap a fresh machine from zero → dotfiles.
#
# Solves the chicken-and-egg where `chezmoi init` needs git to clone, but a fresh
# macOS has no git until the Xcode Command Line Tools exist. Installing Homebrew
# brings the CLT (and git) headlessly; on Linux we install just enough via dnf.
# Then we hand off to chezmoi to clone + apply everything else.
#
# Run on a fresh machine:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/escalonc/dotfiles/main/install.sh)"
set -eu

# ── Banner (blue → cyan gradient, echoing the p10k prompt fade) ───────────────
printf '\n\033[1;38;5;33m'
cat <<'EOF'
██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
EOF
printf '\033[1;38;5;39m'
cat <<'EOF'
██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
EOF
printf '\033[1;38;5;45m'
cat <<'EOF'
██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
EOF
printf '\033[0m\033[2m        escalonc · zero → a fully-provisioned machine\033[0m\n\n'

case "$(uname -s)" in
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      # NONINTERACTIVE (below) aborts unless sudo is pre-authorized; warm the
      # timestamp so the slow CLT + Homebrew install can't hit the sudo timeout.
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
    # A fresh box may lack git, which chezmoi needs to clone. Install just enough;
    # run_onchange_before_system.sh.tmpl installs the full toolchain during apply.
    if ! command -v git >/dev/null 2>&1; then
      echo "→ Installing git + curl via dnf..."
      sudo dnf install -y git curl
    fi
    ;;
esac

echo "→ Handing off to chezmoi (clone + apply)..."
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply escalonc
