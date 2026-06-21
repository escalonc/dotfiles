# Codex Recommendations

Review date: 2026-06-21

Scope: dotfiles workflow for a macOS primary development machine plus a headless Linux remote development box for long-running agent work.

## Highest Priority

1. Add a real tmux config before relying on the devbox.

   For a remote machine where agents keep running while the laptop is offline, tmux is core infrastructure, not a nice-to-have. Add `dot_tmux.conf` with at least:

   - sane prefix/keybindings
   - mouse support
   - large scrollback
   - vi copy mode
   - pane/window indexes starting at 1
   - automatic window renumbering
   - readable status line

2. Add a minimal Neovim config for the Linux default editor.

   The Linux branch sets `EDITOR=nvim`, but no Neovim config is managed. Add a small baseline for emergency remote edits:

   - line numbers
   - sensible indentation
   - search highlighting
   - clipboard behavior
   - split behavior
   - diagnostic-friendly defaults if LSP is added later

3. Decide the remote access model before provisioning.

   The current SSH template is good for macOS: 1Password agent on macOS only, and `~/.ssh/config.local` for machine-local hosts. For the devbox, prefer one of these explicit models:

   - Tailscale + Tailscale SSH as the normal path.
   - Public SSH as a restricted break-glass path.
   - Agent forwarding from the Mac only when actually needed.

   Tailscale SSH is a good fit because it centralizes SSH authorization, works over the tailnet, and avoids distributing normal SSH keys for tailnet SSH sessions.

4. Add a backup and recovery story before agents run unattended.

   A remote machine running agents will accumulate useful state: repos, logs, generated artifacts, and local context. Add restic to B2/Wasabi/S3 plus a small healthcheck before relying on the box.

## Shell

- Re-check the completion setup in `dot_zshrc.tmpl`.

  The file manually runs `autoload -U compinit && compinit` before sourcing Oh My Zsh. The comment says this avoids duplicate compinit churn, but OMZ normally manages completion initialization itself. Validate on macOS and the target Linux devbox with:

  ```bash
  zsh -i -c exit
  ```

  Also watch whether `.zcompdump` is rebuilt unexpectedly.

- Make destructive Docker cleanup harder to run accidentally.

  `dprune="docker system prune -a"` is sharp, especially on a shared or remote development host. Prefer a function that prints what it will do and asks for confirmation.

- Consider adding `~/.zshrc.local` sourcing.

  If machine-local shell overrides are still intended, `dot_zshrc.tmpl` should source `~/.zshrc.local` with a guard near the end.

- Revisit `hist()`.

  `hist() { history | grep "$1"; }` is useful but overlaps with fzf Ctrl-R and does not handle missing arguments or regex characters carefully. It is fine to keep, but low value.

## Git

- Decide whether one personal identity is enough.

  `dot_gitconfig.tmpl` hardcodes a personal noreply email everywhere. If the devbox will ever touch work repos, add an `includeIf` split before first real commits from the box.

- Wire SSH commit signing or drop the TODO.

  The repo notes SSH signing via 1Password as intended but unwired. Make it concrete with:

  ```ini
  [gpg]
    format = ssh
  [commit]
    gpgsign = true
  [user]
    signingkey = ...
  ```

  Then upload the signing public key to GitHub.

- Consider making delta side-by-side optional.

  Side-by-side diffs are good on a wide laptop terminal, but less good over SSH, in tmux panes, or from mobile/tablet clients. Consider defaulting to unified diffs and adding a side-by-side alias.

- Keep `rerere`, `zdiff3`, pull rebase, and autostash.

  These are coherent choices for an experienced solo workflow. Revisit only if they cause confusion in team repos.

## Package Decisions

- Keep the Brewfile focused.

  The current package list is reasonable and not bloated. `tldr` and `hyperfine` are optional but defensible if actually used.

- Add a network inspection tool only if the need returns.

  Bruno covers API workflows, but there is no general network inspector now. That is fine if intentional. If needed later, add Proxyman or Wireshark deliberately.

- Reconsider pnpm only when a real project needs it.

  Node via fnm is enough as a base. If pnpm returns, prefer Corepack or a documented package-manager policy over global installs by habit.

- Document Node upgrade behavior.

  The script installs Node LTS only when no fnm default alias exists. That means "latest LTS" is true on first install only. Either document this as "initial LTS" or add a deliberate `nodeup` command.

## Chezmoi And Bootstrap

- Pin or consciously accept rolling shell dependencies.

  `.chezmoiexternal.toml` tracks `master` archives for Oh My Zsh, Powerlevel10k, and plugins with weekly refresh. That is convenient, but it allows upstream shell behavior to change without a repo diff. For unattended devbox reliability, consider pinning commits/tags or refreshing manually.

- Add a small validation harness.

  A `justfile` would be enough:

  ```bash
  just check
  ```

  Initial checks could include:

  - render chezmoi templates
  - `zsh -n` rendered zsh files
  - `bash -n` rendered scripts
  - shellcheck when available
  - `chezmoi diff` smoke test

- Keep scripts idempotent.

  The current bootstrap scripts are headed in the right direction: OS branches are clear, script-local PATH is set explicitly, and Brewfile hashing retriggers the package step.

## macOS

- Reconfirm `AppleKeyboardUIMode`.

  The current value is `2`, while the review notes mention that `3` was previously preferred for Full Keyboard Access. Decide intentionally after daily use.

- Reconsider always-dark mode only if app-specific issues show up.

  For a personal machine this is fine. There is no need to over-abstract macOS preferences until a second human or very different machine uses the repo.

- Add managed settings only for apps where drift hurts.

  Good candidates:

  - Sublime Text settings
  - Raycast export/import notes
  - Warp theme/settings notes if account sync is insufficient
  - Claude Code settings if they become stable and important

## Linux Devbox

- Install only what the headless box needs.

  The dnf list is reasonable. Defer Docker/container runtime until a real workload requires it.

- Watch locale behavior.

  Locale exports were removed. If SSH/tmux shows `setlocale` warnings, install `glibc-langpack-en` or re-add explicit locale exports.

- Prefer Tailscale for stable naming and access.

  MagicDNS gives the box a stable name independent of Hetzner IP changes. It also makes firewall rules simpler if public SSH becomes break-glass only.

- Add observability for unattended work.

  Minimum useful pieces:

  - uptime/process checks
  - disk usage alerts
  - restic backup healthcheck
  - optional ntfy notifications for long-running agent jobs

## Suggested Next Order

1. Add `dot_tmux.conf`.
2. Add minimal Neovim config.
3. Decide Tailscale/Tailscale SSH vs public SSH-only.
4. Wire Git identity/signing decisions.
5. Add `just check`.
6. Test full apply in a local Linux VM matching the devbox.
7. Provision the real devbox.
8. Add backups and healthchecks.

## Validation Note

This review was static. `chezmoi` was not installed in the local environment used for the review, so templates were not rendered/applied during this pass.
