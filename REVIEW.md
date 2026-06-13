# Personal review checklist

Every repo file appears below. Everything works and is validated — each item is
only the question **"is this what I actually want?"** Check off as you confirm.

**Milestone order: Mac fully workable → Linux → provisioning.**

| Phase | Sections | Done when |
|---|---|---|
| 1. Mac | A (+ Sublime item in D) | `chezmoi diff` empty on the new Mac, and a normal week of daily use surfaces nothing |
| 2. Linux | B (+ tmux/neovim items in D) | full apply in a local Fedora VM: exits 0, `zsh -i -c exit` silent, second apply idempotent |
| 3. Provisioning | C | real Hetzner box up via `tofu apply`, `ssh devbox` works, Claude Code runs in tmux |

---

## A. macOS + chezmoi config

### `.chezmoitemplates/macos-defaults.sh` (✅ reviewed 2026-06-11 — ratified, EXCEPT two settings changed 2026-06-13, see ⚠️ below)
- [x] Dock: autohide ON, delay 0, animation 0.15s, magnification OFF, recents OFF, minimize-to-app ON, "scale" effect
- [x] `mru-spaces = false` — Spaces do NOT reorder by recent use
- [x] Natural scrolling OFF (`swipescrolldirection = false`) — deliberate?
- [x] Tap-to-click ON, three-finger drag ON
- [x] KeyRepeat 2 / InitialKeyRepeat 15 (very fast); press-and-hold accents OFF
- [x] ALL autocorrect / smart quotes / smart dashes / auto-capitalize OFF
- [ ] ⚠️ `AppleKeyboardUIMode` REVERTED to `2` (2026-06-13) — back to the lesser "keyboard navigation" toggle that phase-1 review had deliberately fixed to `3` (Full Keyboard Access). Re-confirm: intended, or a regression to undo?
- [x] Finder: list view, search current folder, folders first, no rename warning (⚠️ `AppleShowAllExtensions` dropped 2026-06-13 — file extensions no longer force-shown)
- [x] Screenshots → `~/Pictures/Screenshots`, png, no shadow
- [x] Dark mode forced; large menu-bar font; double-click title bar = nothing
- [x] Native window tiling fully OFF (Rectangle owns snapping)
- [x] Security: screensaver password immediate (the sudo login-window default was reviewed and REMOVED — script is now fully sudo-free)
- [x] Reduce Motion is a MANUAL step (TCC-protected) — done on new Mac?

### `Brewfile` (✅ reviewed 2026-06-11)
- [x] 21 formulae (pnpm removed 2026-06-13) — `tldr` and `hyperfine` are the flagged low-adoption keepers; earning their slots?
- [x] ~21 apps + fonts (after your Zoom/fonts trim) — one full read top to bottom
- [x] Heads-up: after cutting wireshark (then) and proxyman (now) there's NO network-inspection tool — Bruno covers API calls only; confirm acceptable
- [x] Old Mac: `brew bundle cleanup` to list strays, uninstall what you trimmed

### VS Code — `Library/Application Support/Code/User/settings.json` + `50-editor` extensions
**(⏸ DEFERRED to end — settings.json is "commented out" via a TEMP `Library/` line in `.chezmoiignore`; delete that line when reviewing this section, then `chezmoi apply`)**
- [ ] Re-skim the ~37 carried-over settings (they were yours; 2 added: `chat.disableAIFeatures`, telemetry off)
- [ ] MonoLisa font: paid, installed MANUALLY per machine — done on the new Mac? (fontFamily falls back to Menlo without it)
- [ ] Settings Sync OFF on BOTH Macs
- [ ] Extensions (21): anything missing you reach for / anything never used?
- [ ] Old Mac: `code --uninstall-extension github.copilot github.copilot-chat`

### `dot_zshrc.tmpl` (shared + darwin branch) (✅ reviewed 2026-06-13 — all ratified)
- [x] Plugins (6 in array): `git gh zsh-autosuggestions docker sudo colored-man-pages`; zsh-completions via `fpath+=` BEFORE oh-my-zsh (upstream: avoids double compinit/.zcompdump churn); zsh-syntax-highlighting sourced manually as the FILE'S last line (after fzf/zoxide/p10k widgets exist)
- [x] `BAT_THEME` → "Catppuccin Mocha" (2026-06-12; Mocha is the declared overall theme — see Themes TODO below)
- [x] fzf: `--style=minimal` (2026-06-13, dropped `--border`), 40% height, bat preview (500 lines), `fd --hidden --follow` source
- [x] Docker aliases incl. `dprune -a` (deletes ALL unused images); docker has no runtime on the server yet
- [x] Functions: `serve` (8080), `hist` (duplicates fzf Ctrl-R), `weather`, `jwt-decode`, `extract`, `killport`, `gclone`
- [x] HISTSIZE/SAVEHIST 50000; `HIST_STAMPS yyyy-mm-dd`
- [x] darwin aliases: `zshconfig`/`ohmyzsh`/`hosts` (subl), `cleanup` (rm .DS_Store from CWD down), `brewup`, `flushdns`, `localip`
- [x] `EDITOR="subl --wait"` (darwin) — settled, confirm once

### `dot_zprofile.tmpl` (✅ reviewed 2026-06-13 — all ratified)
- [x] darwin: guarded brew shellenv + Sublime/VS Code CLI dirs on PATH — both editors still the right PATH additions?
- [x] linux branch: just `~/.local/bin` — sufficient?

### `dot_p10k.zsh` (✅ reviewed 2026-06-13 — all ratified)
- [x] It's your wizard output (rainbow, nerdfont-v3, 12h, 2-line) — live with it a week, restyle path is in README

### `dot_gitconfig.tmpl` (✅ reviewed 2026-06-13 — all ratified)
- [x] `user.email` = personal noreply everywhere — includeIf work split: before devbox makes work commits, or accept
- [x] SSH signing via 1Password: stated intent, unwired — wire or drop
- [x] `wip` commits tracked files only; `lg` shows `--all` refs
- [x] Behavior changes you ratified in chat: pull=rebase, zdiff3 markers, autocorrect prompt — revisit after a week of real use

### `dot_gitignore_global` (✅ reviewed 2026-06-13 — trimmed 50→24 lines)
- [x] `.envrc` dropped (direnv removed)
- [x] `.vscode/settings.json` dropped — VS Code settings are now managed; global ignore would hide teams' shared `.vscode/`
- [x] Project artifacts (`node_modules/ dist/ build/ .next/ .nuxt/ .cache/ coverage/`, npm/pnpm logs) dropped — those belong in each repo's committed `.gitignore`, not a global ignore that masks missing entries
- [x] macOS block trimmed to the handful that actually occur; Windows entries (`Thumbs.db`, `ehthumbs.db`) removed
- [x] secrets backstop kept (`.env*`, `*.pem`, `*.key`, `.secrets`) — projects should also ignore these; this is defense-in-depth

### `private_dot_ssh/private_config.tmpl` — DELETED 2026-06-13 (whole template removed)
- [ ] Decide whether to manage SSH config at all. The removed template only set the
  macOS 1Password agent + a (since-removed) devbox host. Re-create when needed —
  the `2BUA8C4S2C.com.1password` path is a fixed AgileBits team ID, identical on every Mac.
  Content to restore (was `private_dot_ssh/private_config.tmpl`):
  ```
  {{- if eq .chezmoi.os "darwin" }}
  # Machine-local, untracked additions (like ~/.zshrc.local); ssh ignores a missing Include.
  Include ~/.ssh/config.local

  Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

  # Hetzner devbox (re-add at phase C): User chris, ForwardAgent yes; IP in ~/.ssh/config.local
  {{- end }}
  ```
- [ ] Other frequent hosts → add blocks (or config.local) when SSH config returns

### chezmoi core files
- [ ] `.chezmoi.toml.tmpl`: Linux-only `headless` prompt; no-TTY ⇒ headless=true (cloud-init path) — logic still right for a future Linux desktop?
- [ ] `.chezmoiexternal.toml`: OMZ/p10k/plugins track `master`, 168h refresh, `exact=true` (your manual edits inside ~/.oh-my-zsh get pruned) — rolling ok, or pin tags?
- [ ] `.chezmoitemplates/dev-env.sh`: the env contract (~/.local/bin, brew, fnm) — anything else every script should see?
- [ ] `.chezmoiignore`: README/REVIEW/Brewfile/.gitignore/.github/.claude/LICENSE/provisioning + non-darwin `Library/` gate — `LICENSE` entry is a ghost (no such file); keep or drop
- [ ] `.gitignore` (repo): only `.DS_Store` — enough?

### macOS-relevant run scripts — `.chezmoiscripts/`
- [ ] `00-bootstrap` darwin: Homebrew via official installer w/ sudo keepalive — comfortable with the curl|bash trust list (brew, chezmoi, OMZ-via-chezmoi, fnm, claude)?
- [ ] `10-packages` darwin: `brew bundle` + `brew analytics off`
- [ ] `30-languages`: Node = "latest LTS at install time", default alias; per-project `.node-version` + `--use-on-cd` covers projects
- [ ] `60-ui-defaults`: thin gate (payload reviewed above)
- [ ] `70-claude`: native installer → npm fallback (pnpm branch removed 2026-06-13); installs `anthropic.claude-code` VS Code extension

---

## B. Linux (devbox software — test in local VM)

- [ ] `00-bootstrap` linux: dnf base = `zsh git curl wget unzip tar gcc gcc-c++ make gnupg2 jq util-linux-user`; chsh to zsh — is the gcc toolchain needed for your workload?
- [ ] `10-packages` linux: dnf = `ripgrep fd-find bat fzf zoxide btop tmux neovim eza git-delta gh httpie`; fnm via vendor installer (unpinned — accepted); pnpm removed 2026-06-13
- [ ] zshrc linux branch: `EDITOR=nvim`, `zshconfig`/`hosts` use $EDITOR, `localip` (hostname -I), `flushdns` (resolvectl)
- [ ] `50-editor`: headless gate ⇒ VS Code skipped on the server — correct
- [ ] Locale exports removed: watch for `setlocale` warnings over ssh/tmux (fix: `glibc-langpack-en` or re-add LANG)
- [ ] OMZ git plugin aliases + p10k prompt over ssh: needs Nerd Font on the CLIENT (Blink/phone, Warp)
- [ ] docker aliases exist but NO container runtime installed — defer or add when needed
- [ ] VM test loop: `orb create fedora:42` → chezmoi one-liner → `zsh -i -c exit` silent → apply twice (idempotent) → delete

---

## C. Provisioning (before first `tofu apply`)

- [ ] `variables.tf`: `cpx41` (8c/16G ~€30/mo), `fsn1`, `image=fedora-42` (CONFIRM still exists: `hcloud image list | grep -i fedora`), `ssh_public_key_path=~/.ssh/id_ed25519.pub` (exists on the applying machine?)
- [ ] `terraform.tfvars`: `ssh_allowed_ips` = your IP/32 (required, fail-closed) — home IP stable enough, or revisit Tailscale idea?
- [ ] `main.tf`: firewall SSH-only (no ICMP — ping won't answer); `prevent_destroy=true` (flip procedure in README); cloud-init edit ⇒ box rebuild
- [ ] `cloud-init.yaml`: user `chris` + NOPASSWD sudo, key-only auth, root keeps laptop key fallback; clones `main` (correct since merge)
- [ ] `outputs.tf`: prints IP + `ssh chris@<ip>`
- [ ] `versions.tf` + `.terraform.lock.hcl`: hcloud `~> 1.48` (1.65 locked, committed) — fine
- [ ] `provisioning/.gitignore`: state/tfvars/plans ignored, lock tracked — fine
- [ ] Secret flow: `TF_VAR_hcloud_token` via `op read` only — 1Password item exists?
- [ ] Re-add the SSH `Host devbox` block to `private_dot_ssh/private_config.tmpl` (removed 2026-06-13): `User chris`, `ForwardAgent yes`, agent-forwarded 1Password (no keys on box); put the `tofu` output IP in `~/.ssh/config.local`

---

## Themes TODO — Catppuccin Mocha everywhere (declared 2026-06-12)

Done: **bat** (built-in theme, `BAT_THEME` in zshrc — delta inherits it for diff syntax).

Chezmoi-manageable (official ports at github.com/catppuccin/<tool>):
- [ ] delta UI colors: official `catppuccin.gitconfig` include (syntax already Mocha via BAT_THEME)
- [ ] fzf: official `--color` string appended to `FZF_DEFAULT_OPTS` (`--style=minimal` already set)
- [ ] zsh-syntax-highlighting: official colors file sourced before the plugin
- [ ] btop: theme file → `~/.config/btop/themes` + config line
- [ ] eza: official `theme.yml` → `~/.config/eza/`
- [ ] Warp: theme YAML → `~/.warp/themes/` (select once in Warp settings)

GUI apps (manual, one-time each):
- [ ] VS Code: `catppuccin.catppuccin-vsc` + icons ext — fold into the DEFERRED VS Code review (replaces Monokai Pro ext + 2 settings keys)
- [ ] Rider/JetBrains: official Catppuccin plugin
- [ ] Sublime Text: official port via Package Control
- [ ] Slack: paste official sidebar color string
- [ ] Brave: Chrome-store Catppuccin theme
- [ ] Raycast: community Mocha theme

When configured (phase 2 decisions): tmux (`catppuccin/tmux`), neovim (`catppuccin/nvim`).
Won't theme: p10k (hand-set segment colors), Claude Code, OrbStack, macOS itself.

---

## D. Housekeeping / meta

- [ ] README: one full top-to-bottom read (edited piecemeal ~15× this week; check for stale claims)
- [ ] `.claude/skills/code-review/`: skim the rewritten SKILL.md once — it reviews YOUR future changes
- [ ] `bash-version` branch: archive or delete
- [ ] Things the repo does NOT manage (decide: deliberate or gap?):
  - [ ] **tmux config** — no `dot_tmux.conf`, but the devbox plan IS "Claude Code in tmux"; vanilla tmux has awkward defaults (prefix, mouse off, small history)
  - [ ] **neovim config** — nvim is `$EDITOR` on the server with zero config (no clipboard, default everything)
  - [ ] **Sublime Text settings** — permanent tier-3 editor, settings unmanaged (`~/Library/Application Support/Sublime Text/Packages/User/`)
  - [ ] Warp (has account sync — probably fine unmanaged), Raycast (manual export), Claude Code `~/.claude/` settings — accept as unmanaged?
- [ ] **pnpm + JS globals** — removed 2026-06-13, to be set up later; restore the `typescript`/`tsx` globals (was `40-pkg-managers`, now deleted) alongside it, and decide whether `70-claude` should regain pnpm ahead of the npm fallback
- [ ] Test harness (offered, parked): `just test` render+lint + Fedora-container e2e — decide after phase 2, when the manual VM loop gets old
- [ ] Parked as separate projects (not repo review): Tailscale instead of IP allowlist, restic+B2 backups + Healthchecks, Packer golden image, ntfy notifications for devbox runs
- [ ] Delete this file when done (or keep as a living audit log)
