# Terminal Workflow Recommendations

Notes from a review of this repo (2026-07-05): what's already covered, and what to add
next for a fully terminal-centric workflow. Roughly ordered by impact within each section.

**Shortlist for maximum return on effort:** 1Password SSH/signing and sesh
(lazygit, fzf-tab, atuin, direnv all landed 2026-07-14).

## Already solid — don't churn

- Ghostty, tmux (resurrect/continuum), zinit (turbo) + fzf-tab/autosuggestions/
  fast-syntax-highlighting, Starship (Ink)
- Modern CLI kit: fzf, zoxide, eza, bat, delta, ripgrep, fd, btop, hyperfine,
  atuin, direnv, lazygit
- Git config already better than most: histogram diff, zdiff3 conflicts, rerere,
  `rebase.updateRefs`, branch sort, delta side-by-side
- macOS defaults script is more thorough than most published ones
- Keep fnm (no mise). (2026-07-12: migrated p10k → starship after all — p10k is
  in maintenance mode and its config was hard to maintain; see tag `pre-starship`.)
  (2026-07-13: dropped starship too — the custom "Ink" config was still bespoke
  upkeep; now OMZ's `refined` theme, zero config to own. Ink lives at `5a510eb`.)
  (2026-07-14: reversed the refined decision — back to starship/Ink, and replaced
  Oh My Zsh entirely with a zinit turbo stack; the refined-era state lives at the
  "Checkpoint: OMZ refined state" commit. Plugin updates are now manual:
  `zinit update --all` — chezmoi's weekly refresh covers only zinit itself.)

## Round 1 — wiring together what's already installed

### 1. 1Password SSH agent + signed commits (biggest QoL win)

`1password` and `1password-cli` are already in the Brewfile, but nothing uses them.
Let 1Password be the SSH agent and sign commits with an SSH key — "Verified" badges
on GitHub, biometric-gated SSH, zero key files on disk.

```gitconfig
[gpg]
    format = ssh
[gpg "ssh"]
    program = /Applications/1Password.app/Contents/MacOS/op-ssh-sign
[commit]
    gpgsign = true
```

Plus `IdentityAgent` in `~/.ssh/config` (see also: manage SSH config via chezmoi, Round 2).

### 2. lazygit

Resolved 2026-07-14: installed, delta pager wired via `~/.config/lazygit/config.yml`
(`LG_CONFIG_FILE` pins the XDG path on macOS), bound to `prefix + g` tmux popup.

### 3. fzf-tab

Resolved 2026-07-14: loaded via zinit turbo (after compinit, before widget-wrapping
plugins), with eza directory previews on cd/zoxide completions.

### 4. tmux session picker — sesh

resurrect/continuum give persistence, but there's no fast way to jump between projects.
[sesh](https://github.com/joshmedeski/sesh) integrates with zoxide: `prefix + T` opens
an fzf popup of sessions + zoxide dirs — pick one, it creates or attaches. Turns tmux
from "a multiplexer" into an actual project workflow.

### 5. atuin

Resolved 2026-07-14: installed, owns Ctrl-R (init last in zshrc; `--disable-up-arrow`
keeps up-arrow on prefix-search). Plain `~/.zsh_history` still accrues as a fallback.
Cross-machine sync not set up yet — `atuin register`/`login` when wanted.

### 6. direnv

Resolved 2026-07-14: installed and hooked in zshrc.

### Smaller Brewfile additions (take or leave)

- `yazi` — terminal file manager with image previews (great in Ghostty)
- `glow` — render markdown in the terminal
- `watchexec` — run a command on file change
- `gh ext install dlvhdr/gh-dash` — PR/issue dashboard TUI

## Round 2 — structural gaps and second-layer upgrades

### 1. Neovim config (biggest remaining piece)

Resolved 2026-07-06: dropped `neovim` from the Brewfile — editing goes through
Sublime on macOS, and Linux falls back to `vi` for `$EDITOR`/git.

### 2. Secrets via chezmoi's 1Password integration

chezmoi has native template functions — e.g. `onepasswordRead "op://Personal/GitHub/token"` —
and `1password-cli` is already installed. API tokens, `.npmrc` auth, work-vs-personal
gitconfig emails can live in templates that resolve at `chezmoi apply` time; nothing
sensitive touches the repo. Also manage `~/.ssh/config` as `dot_ssh/private_config`
with the `IdentityAgent` line so a fresh machine has working SSH the moment 1Password
signs in.

### tmux, second layer

- Popup scratch terminal: `bind g display-popup -E -w 80% -h 80%` — floating throwaway
  shell; or bind one that runs lazygit directly
- `extrakto` — fzf-pick any word/path/URL from scrollback and paste it, no mouse;
  slots into `.chezmoiexternal.toml`
- `tmux-fzf-url` — open any URL visible in the pane from the keyboard

### Git, second layer

- `git-absorb` — turns staged fixes into `fixup!` commits against the right commits
  automatically; companion to the `oops` alias and `rebase.updateRefs`
- `git maintenance start` — background prefetch/gc per repo; could go in a chezmoi
  run-once script

### Shell ergonomics

- `zsh-abbr` — fish-style abbreviations: type `dc`, hit space, expands to
  `docker compose` inline; history records the real command
- `just` — per-project command runner (`just test`, `just deploy`); nicer than
  Makefiles for project verbs

### Brewfile fill-ins

- `lazydocker` — docker aliases + OrbStack exist but no TUI
- `mas` — lets the Brewfile manage App Store apps so `install.sh` truly covers
  a fresh machine
- `dust` / `duf` — du/df in the same modern-CLI family as eza/bat

## Explicitly not worth doing

- Adding to the macOS defaults script — already thorough
- Managing Raycast settings via chezmoi — not cleanly file-manageable
- `thefuck` / `navi`-style helpers — autosuggestions + fzf already cover that ground
