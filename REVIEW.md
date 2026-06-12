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

### `.chezmoitemplates/macos-defaults.sh` (✅ reviewed 2026-06-11 — all ratified)
- [x] Dock: autohide ON, delay 0, animation 0.15s, magnification OFF, recents OFF, minimize-to-app ON, "scale" effect
- [x] `mru-spaces = false` — Spaces do NOT reorder by recent use
- [x] Natural scrolling OFF (`swipescrolldirection = false`) — deliberate?
- [x] Tap-to-click ON, three-finger drag ON
- [x] KeyRepeat 2 / InitialKeyRepeat 15 (very fast); press-and-hold accents OFF
- [x] ALL autocorrect / smart quotes / smart dashes / auto-capitalize OFF
- [x] `AppleKeyboardUIMode 3` — Full Keyboard Access (was 2 = lesser "keyboard navigation" toggle; caught during phase-1 review)
- [x] Finder: list view, search current folder, folders first, all extensions, no rename warning
- [x] Screenshots → `~/Pictures/Screenshots`, png, no shadow
- [x] Dark mode forced; large menu-bar font; double-click title bar = nothing
- [x] Native window tiling fully OFF (Rectangle owns snapping)
- [x] Security: screensaver password immediate (the sudo login-window default was reviewed and REMOVED — script is now fully sudo-free)
- [x] Reduce Motion is a MANUAL step (TCC-protected) — done on new Mac?

### `Brewfile` (you curated it this week — final skim)
- [ ] 22 formulae — `tldr` and `hyperfine` are the flagged low-adoption keepers; earning their slots?
- [ ] ~21 apps + fonts (after your Zoom/fonts trim) — one full read top to bottom
- [ ] Heads-up: after cutting wireshark (then) and proxyman (now) there's NO network-inspection tool — Bruno covers API calls only; confirm acceptable
- [ ] Old Mac: `brew bundle cleanup` to list strays, uninstall what you trimmed

### VS Code — `Library/Application Support/Code/User/settings.json` + `50-editor` extensions
- [ ] Re-skim the ~37 carried-over settings (they were yours; 2 added: `chat.disableAIFeatures`, telemetry off)
- [ ] MonoLisa font: paid, installed MANUALLY per machine — done on the new Mac? (fontFamily falls back to Menlo without it)
- [ ] Settings Sync OFF on BOTH Macs
- [ ] Extensions (21): anything missing you reach for / anything never used?
- [ ] Old Mac: `code --uninstall-extension github.copilot github.copilot-chat`

### `dot_zshrc.tmpl` (shared + darwin branch)
- [ ] Plugins (8): `git gh zsh-autosuggestions zsh-completions docker sudo colored-man-pages zsh-syntax-highlighting`
- [ ] `BAT_THEME="Dracula"` vs Monokai Pro editor theme — intentional mismatch?
- [ ] fzf: 40% height, bat preview (500 lines), `fd --hidden --follow` source
- [ ] Docker aliases incl. `dprune -a` (deletes ALL unused images); docker has no runtime on the server yet
- [ ] Functions: `serve` (8080), `hist` (duplicates fzf Ctrl-R), `weather`, `jwt-decode`, `extract`, `killport`, `gclone`
- [ ] HISTSIZE/SAVEHIST 50000; `HIST_STAMPS yyyy-mm-dd`
- [ ] darwin aliases: `zshconfig`/`ohmyzsh`/`hosts` (subl), `cleanup` (rm .DS_Store from CWD down), `brewup`, `flushdns`, `localip`
- [ ] `EDITOR="subl --wait"` (darwin) — settled, confirm once

### `dot_zprofile.tmpl`
- [ ] darwin: guarded brew shellenv + Sublime/VS Code CLI dirs on PATH — both editors still the right PATH additions?
- [ ] linux branch: just `~/.local/bin` — sufficient?

### `dot_p10k.zsh`
- [ ] It's your wizard output (rainbow, nerdfont-v3, 12h, 2-line) — live with it a week, restyle path is in README

### `dot_gitconfig.tmpl`
- [ ] `user.email` = personal noreply everywhere — includeIf work split: before devbox makes work commits, or accept
- [ ] SSH signing via 1Password: stated intent, unwired — wire or drop
- [ ] `wip` commits tracked files only; `lg` shows `--all` refs
- [ ] Behavior changes you ratified in chat: pull=rebase, zdiff3 markers, autocorrect prompt — revisit after a week of real use

### `dot_gitignore_global` (never reviewed — affects EVERY repo incl. work)
- [ ] `.envrc` ignored, but direnv is removed — keep or drop?
- [ ] `.vscode/settings.json` ignored, but you now MANAGE VS Code settings — teams sharing .vscode/ become invisible to you
- [ ] `.idea/`, `dist/ build/ .next/ .nuxt/ .cache/ coverage/ node_modules/` — broad; fine?
- [ ] secrets section (`.env*`, `*.pem`, `*.key`, `.secrets`) — complete for your stacks?

### `private_dot_ssh/private_config.tmpl`
- [ ] `Host *` → 1Password IdentityAgent; agent enabled in 1Password on the NEW Mac?
- [ ] `Host devbox`: `User chris`, `ForwardAgent yes`; IP goes in `~/.ssh/config.local` post-provision
- [ ] Other frequent hosts → add blocks (or config.local)

### chezmoi core files
- [ ] `.chezmoi.toml.tmpl`: Linux-only `headless` prompt; no-TTY ⇒ headless=true (cloud-init path) — logic still right for a future Linux desktop?
- [ ] `.chezmoiexternal.toml`: OMZ/p10k/plugins track `master`, 168h refresh, `exact=true` (your manual edits inside ~/.oh-my-zsh get pruned) — rolling ok, or pin tags?
- [ ] `.chezmoitemplates/dev-env.sh`: the env contract (~/.local/bin, brew, fnm) — anything else every script should see?
- [ ] `.chezmoiignore`: README/REVIEW/Brewfile/.gitignore/.github/.claude/LICENSE/provisioning + non-darwin `Library/` gate — `LICENSE` entry is a ghost (no such file); keep or drop
- [ ] `.gitignore` (repo): only `.DS_Store` — enough?

### macOS-relevant run scripts — `.chezmoiscripts/`
- [ ] `00-bootstrap` darwin: Homebrew via official installer w/ sudo keepalive — comfortable with the curl|bash trust list (brew, chezmoi, OMZ-via-chezmoi, fnm, pnpm, claude)?
- [ ] `10-packages` darwin: `brew bundle` + `brew analytics off`
- [ ] `30-languages`: Node = "latest LTS at install time", default alias; per-project `.node-version` + `--use-on-cd` covers projects
- [ ] `40-pkg-managers`: pnpm globals = `typescript tsx` only — both still wanted as globals?
- [ ] `60-ui-defaults`: thin gate (payload reviewed above)
- [ ] `70-claude`: native installer → pnpm → npm fallback chain; installs `anthropic.claude-code` VS Code extension

---

## B. Linux (devbox software — test in local VM)

- [ ] `00-bootstrap` linux: dnf base = `zsh git curl wget unzip tar gcc gcc-c++ make gnupg2 jq util-linux-user`; chsh to zsh — is the gcc toolchain needed for your workload?
- [ ] `10-packages` linux: dnf = `ripgrep fd-find bat fzf zoxide btop tmux neovim eza git-delta gh httpie`; fnm + pnpm via vendor installers (unpinned — accepted)
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
- [ ] Test harness (offered, parked): `just test` render+lint + Fedora-container e2e — decide after phase 2, when the manual VM loop gets old
- [ ] Parked as separate projects (not repo review): Tailscale instead of IP allowlist, restic+B2 backups + Healthchecks, Packer golden image, ntfy notifications for devbox runs
- [ ] Delete this file when done (or keep as a living audit log)
