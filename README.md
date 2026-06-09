# dotfiles

> `> one command. fresh Mac, fully provisioned. _`

Personal development setup managed by [chezmoi](https://www.chezmoi.io), across
two kinds of machine: a **macOS** workstation (Apple Silicon) and a **headless
Fedora Linux** dev box. Same repo drives both — packages, shell config, language
runtimes, editor extensions, macOS defaults, and a small set of dotfiles. The
`provisioning/` directory additionally stands up the Linux box itself on Hetzner
with OpenTofu. Re-runnable — safe to apply twice.

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
Restart the terminal (or `source ~/.zshrc`) and run `p10k configure`. Enable the
1Password SSH agent, add your public key to GitHub / GitLab, then `gh auth login`.
Launch Claude Code, OrbStack, Raycast, and CleanShot once to finish their setup.
Finally, set JetBrains Mono Nerd Font in your terminal and restart macOS to
apply system defaults.

## What It Sets Up

| Area | Details |
| --- | --- |
| Packages | macOS: Homebrew formulae, GUI apps, fonts (`Brewfile`). Linux: `dnf` packages + release binaries into `~/.local/bin` |
| Shell | zsh, Oh My Zsh, Powerlevel10k, fzf, atuin, zoxide |
| Languages | Node via fnm; pnpm globals |
| Editor | VS Code extensions — GUI machines only; skipped on a headless box (see `run_onchange_before_50-editor.sh.tmpl`) |
| Git/SSH | Git config, global ignore rules; 1Password SSH agent on macOS (agent-forwarding/HTTPS on the server) |
| macOS | Dock, Finder, keyboard, trackpad, screenshots, security defaults (skipped on Linux) |
| Provisioning | `provisioning/` — OpenTofu/Hetzner config that creates the Linux dev box (machine, not software) |

## Layout

```text
.
├── Brewfile                                        # Homebrew formulae, casks, fonts (macOS)
├── .chezmoi.toml.tmpl                              # per-machine config; asks `headless` on Linux
├── .chezmoitemplates/dev-env.sh                    # shared PATH/fnm prelude, included by run scripts
├── dot_zshrc.tmpl                                  # → ~/.zshrc (per-OS aliases/env)
├── dot_zprofile.tmpl                               # → ~/.zprofile (login-shell PATH)
├── dot_gitconfig.tmpl                              # → ~/.gitconfig
├── dot_gitignore_global                            # → ~/.gitignore_global
├── private_dot_ssh/private_config.tmpl             # → ~/.ssh/config (dir 700, file 600)
├── run_onchange_before_00-bootstrap.sh.tmpl        # macOS: Xcode CLT + Homebrew. Linux: dnf base + zsh
├── run_onchange_before_10-packages.sh.tmpl         # macOS: brew bundle. Linux: dnf + release binaries
├── run_onchange_before_20-shell.sh                 # Oh My Zsh + community plugins
├── run_onchange_before_30-languages.sh.tmpl        # Node (fnm)
├── run_onchange_before_40-pkg-managers.sh.tmpl     # pnpm globals
├── run_onchange_before_50-editor.sh.tmpl           # VS Code extensions (skipped if headless)
├── run_onchange_after_60-system-defaults.sh.tmpl   # macOS Dock/Finder/keyboard (no-op on Linux)
├── run_onchange_after_70-claude.sh.tmpl            # Claude Code install
└── provisioning/                                   # OpenTofu: create the Hetzner Linux box (see its README)
```

`run_onchange_*` scripts re-run whenever their content changes (so editing the
Brewfile re-triggers `brew bundle`, editing the system-defaults script re-applies
those preferences). Each is written to be idempotent, so re-runs are safe.
`*_before_*` runs before dotfiles are applied; `*_after_*` runs after. `.tmpl`
files are Go templates that branch per OS via `{{ if eq .chezmoi.os "darwin" }}`
(macOS) / `{{ else if eq .chezmoi.os "linux" }}` (Fedora).

Each `run_*` script runs as its own process, so environment set by one is **not**
visible to the next. Scripts that need user-local tools (fnm's Node, pnpm,
`~/.local/bin`) include the shared prelude — `{{ template "dev-env.sh" . }}` —
which re-establishes that environment. Edit the prelude once in
`.chezmoitemplates/dev-env.sh` rather than per script.

## Customize

| Change | File |
| --- | --- |
| Add a CLI tool or GUI app | `Brewfile` |
| Change shell config | `dot_zshrc` |
| Change Git config | `dot_gitconfig` |
| Add a VS Code extension | `run_onchange_before_50-editor.sh.tmpl` |
| Add global JS tools | `run_onchange_before_40-pkg-managers.sh.tmpl` |
| Tweak macOS defaults | `run_onchange_after_60-system-defaults.sh.tmpl` |
| Machine-local shell overrides | `~/.zshrc.local` (untracked) |

After editing, run `chezmoi apply` (or `chezmoi update` to pull first).

## Notes

Intentionally personal. Two supported machines today: a macOS Apple Silicon
workstation and a headless Fedora Linux dev box; the scripts branch on
`.chezmoi.os` and on the `headless` flag, not on a hardcoded host. Read the
`run_*` scripts before applying on a machine you care about. Adding a third OS
(or a Linux *desktop*, which is non-headless) is additive — extend the existing
`{{ if }}` branches and the `Brewfile`/`dnf` package lists.
