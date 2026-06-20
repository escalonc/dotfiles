# dotfiles

> `> one command. fresh Mac, fully provisioned. _`

Personal development setup managed by [chezmoi](https://www.chezmoi.io), across
two kinds of machine: a **macOS** workstation (Apple Silicon) and a **headless
Fedora Linux** dev box. Same repo drives both — packages, shell config, language
runtimes, macOS defaults, and a small set of dotfiles. The `provisioning/`
directory additionally stands up the Linux box itself on Hetzner with OpenTofu.
Re-runnable — safe to apply twice.

![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-black?style=flat-square&logo=apple)
![Linux](https://img.shields.io/badge/Linux-Fedora-51A2DA?style=flat-square&logo=fedora)
![Shell](https://img.shields.io/badge/shell-zsh-blue?style=flat-square)
![chezmoi](https://img.shields.io/badge/managed%20by-chezmoi-7B68EE?style=flat-square)

## Install

One command. Installs chezmoi, clones this repo into `~/.local/share/chezmoi`,
applies dotfiles, runs setup hooks. The same command works on macOS and Fedora —
chezmoi detects the OS and runs the right branch of each script:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply escalonc/dotfiles
```

On Linux you're asked once whether the machine is **headless** (a server → no GUI
apps); answer yes for the dev box. Re-apply anytime: `chezmoi update` (pulls +
reapplies). Just preview: `chezmoi diff`.

**Provisioning the Linux box from scratch** (create the Hetzner server *and* run
the above automatically on first boot) is a separate, optional step — see
[`provisioning/README.md`](provisioning/README.md).

## After Install

These are the macOS workstation steps (the headless server needs none of them).
Restart the terminal (or `source ~/.zshrc`) — the prompt is preconfigured
(`dot_p10k.zsh`; rerun `p10k configure` only to restyle it). Enable the
1Password SSH agent, add your public key to GitHub / GitLab, then `gh auth login`.
Install Claude Code (`curl -fsSL https://claude.ai/install.sh | bash`; it
self-updates thereafter), and launch OrbStack, Raycast, and CleanShot once to
finish their setup. Finally, set JetBrains Mono Nerd Font in your terminal and
restart macOS to apply system defaults.

## What It Sets Up

| Area | Details |
| --- | --- |
| Packages | macOS: Homebrew formulae, GUI apps, fonts (`Brewfile`). Linux: `dnf` packages + the fnm installer into a user dir |
| Shell | zsh, Oh My Zsh, Powerlevel10k, fzf, zoxide — OMZ/p10k/plugins arrive via `.chezmoiexternal.toml` (chezmoi-managed, weekly refresh) |
| Languages | Node via fnm (latest LTS, set as default) |
| Git | Git config + global ignore rules (the 1Password SSH agent is enabled manually — see *After Install*) |
| macOS | Dock, Finder, keyboard, trackpad, screenshots, security defaults (skipped on Linux) |
| Provisioning | `provisioning/` — OpenTofu/Hetzner config that creates the Linux dev box (machine, not software) |

## Layout

```text
.
├── Brewfile                                          # Homebrew formulae, casks, fonts (macOS)
├── .chezmoi.toml.tmpl                                # per-machine config; asks `headless` on Linux
├── .chezmoiexternal.toml                             # Oh My Zsh + p10k + zsh plugins, fetched/refreshed by chezmoi
├── .chezmoitemplates/macos-defaults.sh               # the `defaults write` payload, included by the ui-defaults script
├── .chezmoiscripts/
│   ├── run_onchange_before_system.sh.tmpl            # bootstrap + packages + Node: macOS (Homebrew) / Linux (dnf + fnm)
│   └── run_onchange_after_ui-defaults.sh.tmpl        # macOS Dock/Finder/keyboard (no-op on Linux)
├── dot_zshrc.tmpl                                    # → ~/.zshrc (per-OS aliases/env)
├── dot_p10k.zsh                                      # → ~/.p10k.zsh (prompt; from `p10k configure`)
├── dot_zprofile.tmpl                                 # → ~/.zprofile (login-shell PATH)
├── dot_gitconfig.tmpl                                # → ~/.gitconfig
├── dot_gitignore_global                              # → ~/.gitignore_global
└── provisioning/                                     # OpenTofu: create the Hetzner Linux box (see its README)
```

`run_onchange_*` scripts re-run whenever their *rendered* content changes (so
editing the Brewfile re-triggers `brew bundle`, and editing an included template
like `macos-defaults.sh` re-applies those preferences). Each is written to be idempotent, so re-runs are safe.
`*_before_*` runs before dotfiles are applied; `*_after_*` runs after. `.tmpl`
files are Go templates that branch per OS via `{{ if eq .chezmoi.os "darwin" }}`
(macOS) / `{{ else if eq .chezmoi.os "linux" }}` (Fedora).

Each `run_*` script runs as its own process, so environment set by one is **not**
visible to the next (and `run_before_*` runs before your dotfiles even exist).
So the `system` script re-establishes what it needs inline before using it — `brew` on
macOS, `~/.local/bin` on Linux — rather than relying on your shell config.

## Customize

| Change | File |
| --- | --- |
| Add a CLI tool or GUI app | `Brewfile` |
| Change shell config | `dot_zshrc` |
| Change Git config | `dot_gitconfig` |
| Bump/pin the shell stack (OMZ, p10k, plugins) | `.chezmoiexternal.toml` |
| Tweak macOS defaults | `.chezmoitemplates/macos-defaults.sh` |
| Restyle the prompt | rerun `p10k configure`, then copy `~/.p10k.zsh` over `dot_p10k.zsh` |
| Machine-local shell overrides | `~/.zshrc.local` (untracked) |

After editing, run `chezmoi apply` (or `chezmoi update` to pull first).

## Notes

Intentionally personal. Two supported machines today: a macOS Apple Silicon
workstation and a headless Fedora Linux dev box; the scripts branch on
`.chezmoi.os` and on the `headless` flag, not on a hardcoded host. Read the
`run_*` scripts before applying on a machine you care about. Adding a third OS
(or a Linux *desktop*, which is non-headless) is additive — extend the existing
`{{ if }}` branches and the `Brewfile`/`dnf` package lists.
