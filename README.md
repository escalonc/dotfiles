# dotfiles

> `> one command. fresh machine, fully provisioned. _`

Personal setup for a **macOS** (Apple Silicon) workstation and a **headless
Fedora Linux** dev box, managed by [chezmoi](https://www.chezmoi.io). One repo
drives both; scripts branch on OS and on a `headless` flag. Idempotent — safe
to apply twice.

## Install

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/escalonc/dotfiles/main/install.sh)"
```

Bootstraps the essentials (Homebrew on macOS, git on Linux), then runs
`chezmoi init --apply` on this repo. On Linux you're asked once whether the
machine is headless (yes for a server).

## Usage

```bash
chezmoi diff      # preview what would change
chezmoi update    # pull latest + reapply
chezmoi apply     # reapply local source state
```

## Layout

The source is the source of truth — this README deliberately doesn't duplicate
it. The repo follows plain [chezmoi conventions](https://www.chezmoi.io/reference/source-state-attributes/):
`dot_*` → `~/.*`, `dot_config/*` → `~/.config/*`, `.tmpl` files are Go
templates branching per OS, and `.chezmoiscripts/run_onchange_*` scripts re-run
whenever their rendered content changes (e.g. editing `Brewfile` re-triggers
`brew bundle`). Start with `install.sh`, `Brewfile`, and
`.chezmoiscripts/` to see what a fresh machine gets.
