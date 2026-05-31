# dotfiles

> `> one command. fresh Mac, fully provisioned. _`

Personal macOS development setup managed by [chezmoi](https://www.chezmoi.io).
Homebrew packages, shell config, language runtimes, editor extensions, macOS
defaults, and a small set of dotfiles. Re-runnable — safe to apply twice.

![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-black?style=flat-square&logo=apple)
![Shell](https://img.shields.io/badge/shell-zsh-blue?style=flat-square)
![chezmoi](https://img.shields.io/badge/managed%20by-chezmoi-7B68EE?style=flat-square)

## Install

One command. Installs chezmoi, clones this repo into `~/.local/share/chezmoi`,
applies dotfiles, runs setup hooks:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply escalonc/dotfiles
```

Re-apply anytime: `chezmoi update` (pulls + reapplies). Just preview: `chezmoi diff`.

## After Install

Restart the terminal (or `source ~/.zshrc`) and run `p10k configure`. Enable the
1Password SSH agent, add your public key to GitHub / GitLab, then `gh auth login`.
Launch Claude Code, OrbStack, Raycast, and CleanShot once to finish their setup.
Finally, set JetBrains Mono Nerd Font in your terminal and restart macOS to
apply system defaults.

## What It Sets Up

| Area | Details |
| --- | --- |
| Packages | Homebrew formulae, GUI apps, fonts (`Brewfile`) |
| Shell | zsh, Oh My Zsh, Powerlevel10k, fzf, atuin, zoxide |
| Languages | Node via fnm, Python via uv, Rust via rustup |
| Editor | Visual Studio Code with extensions (see `run_onchange_before_50-editor.sh`) |
| Git/SSH | Git config, global ignore rules, 1Password SSH agent |
| macOS | Dock, Finder, keyboard, trackpad, screenshots, security defaults |

## Layout

```text
.
├── Brewfile                                        # Homebrew formulae, casks, fonts
├── dot_zshrc                                       # → ~/.zshrc
├── dot_gitconfig                                   # → ~/.gitconfig
├── dot_gitignore_global                            # → ~/.gitignore_global
├── private_dot_ssh/private_config                  # → ~/.ssh/config (dir 700, file 600)
├── run_onchange_before_00-bootstrap.sh.tmpl        # Xcode CLT + Homebrew preflight
├── run_onchange_before_10-packages.sh.tmpl         # Packages: brew bundle (Linux branch reserved)
├── run_onchange_before_20-shell.sh                 # Oh My Zsh + community plugins
├── run_onchange_before_30-languages.sh             # Node (fnm), Python (uv), Rust (rustup)
├── run_onchange_before_40-pkg-managers.sh          # pnpm globals + uv tools
├── run_onchange_before_50-editor.sh                # VS Code extensions
├── run_onchange_after_60-system-defaults.sh.tmpl   # macOS Dock/Finder/keyboard (Linux reserved)
└── run_onchange_after_70-claude.sh                 # Claude Code install
```

`run_onchange_*` scripts re-run whenever their content changes (so editing the
Brewfile re-triggers `brew bundle`, editing the system-defaults script re-applies
those preferences). Each is written to be idempotent, so re-runs are safe.
`*_before_*` runs before dotfiles are applied; `*_after_*` runs after. `.tmpl`
files are Go templates that gate macOS-only steps via `{{ if eq .chezmoi.os "darwin" }}`.

## Customize

| Change | File |
| --- | --- |
| Add a CLI tool or GUI app | `Brewfile` |
| Change shell config | `dot_zshrc` |
| Change Git config | `dot_gitconfig` |
| Add a VS Code extension | `run_onchange_before_50-editor.sh` |
| Add global JS/Python tools | `run_onchange_before_40-pkg-managers.sh` |
| Tweak macOS defaults | `run_onchange_after_60-system-defaults.sh.tmpl` |
| Machine-local shell overrides | `~/.zshrc.local` (untracked) |

After editing, run `chezmoi apply` (or `chezmoi update` to pull first).

## Notes

Intentionally personal and macOS-focused. Read the `run_*.sh` scripts before
applying on a machine you care about. The Linux branch is reserved (every
macOS-only step is wrapped in `{{ if eq .chezmoi.os "darwin" }}`); adding apt /
pacman package lists and per-OS `dot_zshrc.tmpl` branches is additive when
that time comes.
