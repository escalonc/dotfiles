#!/usr/bin/env bash
# curl -fsSL https://raw.githubusercontent.com/escalonc/dotfiles/main/bootstrap.sh | bash
set -euo pipefail

DOTFILES_REPO="https://github.com/escalonc/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
LOG_FILE="$HOME/dev-setup.log"

# Capture all bootstrap output (including the Homebrew install) to the log.
# Sentinel tells setup.sh not to install its own tee on top of this one.
export _DEV_SETUP_LOGGING=1
exec > >(tee -a "$LOG_FILE") 2>&1
echo "━━━ Bootstrap started at $(date) ━━━"

# ── Homebrew ─────────────────────────────────────────────────────────────────
echo "Installing Xcode Command Line Tools + Homebrew..."
if ! command -v brew &>/dev/null; then
  if ! NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    echo "FATAL: Homebrew installer failed. See $LOG_FILE for details." >&2
    exit 1
  fi
fi

# Verify brew is actually present at the expected prefix.
BREW_PREFIX="/usr/local"
[[ "$(uname -m)" == "arm64" ]] && BREW_PREFIX="/opt/homebrew"
if [ ! -x "$BREW_PREFIX/bin/brew" ]; then
  echo "FATAL: Homebrew not found at $BREW_PREFIX/bin/brew after install" >&2
  exit 1
fi

eval "$($BREW_PREFIX/bin/brew shellenv)"
touch "$HOME/.zprofile"
# Match only an active (uncommented) shellenv line — commented-out lines
# shouldn't block re-adding the active one.
grep -qE '^[[:space:]]*eval.*brew shellenv' "$HOME/.zprofile" || \
  echo "eval \"\$($BREW_PREFIX/bin/brew shellenv)\"" >> "$HOME/.zprofile"

# ── Dotfiles repo ────────────────────────────────────────────────────────────
echo "Cloning dotfiles..."
if [ -d "$DOTFILES_DIR" ]; then
  # Refuse to proceed if the repo is mid-rebase; setup.sh would source files
  # with conflict markers and explode in confusing ways.
  if [ -d "$DOTFILES_DIR/.git/rebase-merge" ] || [ -d "$DOTFILES_DIR/.git/rebase-apply" ]; then
    echo "  ! ~/.dotfiles is mid-rebase. Fix manually first:" >&2
    echo "      cd $DOTFILES_DIR && git rebase --abort" >&2
    exit 1
  fi

  echo "  ~/.dotfiles already exists, pulling latest..."
  # --autostash so symlinked dotfile edits don't abort the pull.
  if ! git -C "$DOTFILES_DIR" pull --rebase --autostash; then
    # The pull may have left the repo mid-rebase, OR finished the rebase but
    # failed reapplying the autostash (which removes .git/rebase-* but leaves
    # unmerged files with conflict markers). Check BOTH before continuing —
    # running setup.sh against conflict markers in scripts/*.sh explodes.
    if [ -d "$DOTFILES_DIR/.git/rebase-merge" ] || [ -d "$DOTFILES_DIR/.git/rebase-apply" ]; then
      echo "  ! pull left ~/.dotfiles mid-rebase. Fix manually first:" >&2
      echo "      cd $DOTFILES_DIR && git rebase --abort" >&2
      exit 1
    fi
    if [ -n "$(git -C "$DOTFILES_DIR" ls-files -u 2>/dev/null)" ]; then
      echo "  ! pull left unmerged files in ~/.dotfiles (autostash conflict)." >&2
      echo "      Resolve conflicts or: cd $DOTFILES_DIR && git checkout -- . && git stash pop" >&2
      exit 1
    fi
    echo "  ! pull failed — continuing with existing local copy"
    # Deterministic stash check (avoids the pipefail/SIGPIPE footgun of piping
    # `git stash list` into grep/head).
    stash_list=$(git -C "$DOTFILES_DIR" stash list 2>/dev/null || true)
    if [ -n "$stash_list" ]; then
      echo "  ! your local edits may be in 'git stash list':"
      echo "$stash_list" | head -3
    fi
  fi
else
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# ── Hand off to setup.sh ─────────────────────────────────────────────────────
echo "Running setup..."
cd "$DOTFILES_DIR"
chmod +x setup.sh
./setup.sh
