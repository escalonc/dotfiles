# Recommendations — dotfiles review

> Review by Claude on 2026-06-21. Focus: macOS workstation + headless Linux
> devbox for running agents while away.
>
> Scope notes: distro choice is treated as **settled / out of scope**.
> `README.md` and `REVIEW.md` are treated as **stale and are NOT used as
> sources** — every claim below is grounded in the actual config files
> (`Brewfile`, `dot_*`, `.chezmoi*`, `private_dot_ssh/*`) and the live
> filesystem / git state. Files referenced by path:line.

## Overall

Genuinely well-built. The chezmoi structure is correct where people usually get
it wrong: `run_onchange` with embedded content hashes, per-process PATH
re-establishment, idempotency, and comments that explain *why* (compinit
ordering in `dot_zshrc.tmpl`, `IdentityAgent` Linux-gating in the ssh config,
the sudo keepalive in the bootstrap script). Phase 1 (Mac) is solid.

The thing worth leading with: **your stated #1 goal — a remote Linux box running
agents while you're away — is the least-built part of the repo.**

---

## Headline: the remote-agent pieces don't exist yet

Grounded in `.chezmoiignore` (which lists them) vs. the live filesystem (which
doesn't have them):

- `provisioning/` **does not exist** — no IaC to stand up or rebuild the box.
- `.claude/` **does not exist** — no managed Claude Code config/hooks/agents.
- No `tmux`/multiplexer config, no notifications, no Tailscale — all absent from
  the tree. For unattended remote agents these are **core, not optional.**

So the agent workflow is essentially greenfield. The rest of this doc is about
building it deliberately, plus tightening the Mac/shell pieces that already exist.

---

## Priority gaps for the agent workflow

### 1. A detached agent has no credential — breaks "agents running while away"

`private_dot_ssh/private_config.tmpl` only configures an `IdentityAgent` (the
1Password agent) in the **darwin** branch; the Linux branch gets nothing but
`Include ~/.ssh/config.local`. And `Brewfile:60` installs `1password-cli` as a
**macOS-only cask** — the Linux box has no 1Password/secrets story at all.

That means the box's only path to keys is a **forwarded** agent from the Mac,
which is alive *only while you're connected.* Close the laptop →
`SSH_AUTH_SOCK` on the box points at a dead socket → a detached agent that tries
to `git push` / clone a private repo **fails silently while you're away.**

Fix — give the box a credential that outlives your SSH session:
- a dedicated **deploy key / machine key** (scoped, revocable), or
- a **1Password service account** + `op` CLI installed on Linux.

**This is the single most important hole for the goal.**

### 2. Add Tailscale; don't gate access on a static home IP

A fail-closed `your-IP/32` firewall rule is hostile to "check on agents from
anywhere." Home IP rotates, or you're on cellular / café wifi / your phone →
locked out of your own box. Tailscale fixes it: identity-based access from
laptop *and phone*, Tailscale SSH (no key management), then close port 22 to the
public internet entirely.

### 3. Notifications (none exist today)

Unattended agents need a push when one finishes or blocks on input. Claude Code
has `Stop` and `Notification` hooks — wire one to curl **ntfy / Pushover /
Telegram**. Highest value-per-effort item on the list.

### 4. Mobile + flaky-network survival

"Not in my laptop" → phone/iPad. Add **mosh** to the devbox (survives sleep, IP
changes, roaming far better than ssh; plain ssh from a phone drops constantly).
Blink Shell + Tailscale + mosh + multiplexer = reattach to a running agent from
anywhere.

### 5. Pick the multiplexer deliberately

No multiplexer config exists yet — free choice. **zellij** gives session
resurrection, sane defaults, and a friendlier "reattach and see what the agent
did" UX out of the box; tmux needs `resurrect`+`continuum` bolted on to match.
Separate question either way: does the session survive a **reboot**? That's a
systemd-user-service decision, not a multiplexer one.

### 6. Agent safety on an unattended box

Autonomous agents + no human = think about blast radius now. If the box is
provisioned from IaC (the stated plan), keep it genuinely disposable: commit
Claude Code permission/sandbox settings to the box, and auto-push frequently so
work isn't trapped in box-local scratch if you rebuild it.

---

## Improvements to existing decisions

**`.chezmoiexternal.toml` tracks `master` on 5 repos, `exact=true`, weekly
refresh** — riskiest line in the repo. A bad upstream commit silently breaks
your shell on next `apply`, on **both** machines, with no pin to roll back to.
p10k and the zsh plugins cut releases. **Pin to tags**, bump deliberately.

**Consider `mise` instead of `fnm`** — only Node is managed (`Brewfile:28` +
the bootstrap script). `mise` replaces fnm + pyenv + goenv + etc., installs
identically on macOS and Linux, hooks the shell like fnm, and adds env + tasks.
One runtime manager identical on both boxes beats per-language tools for a
cross-OS setup.

**Manage `~/.claude/` via chezmoi** (currently excluded by `.chezmoiignore`).
Your Claude Code config — settings, hooks, the notification hook from #3, agents
— is exactly what you want **identical on Mac and devbox.** Nothing exists here
yet; big opportunity given the goal.

**gitconfig niceties** (safe, cross-OS; `dot_gitconfig.tmpl`):
`rebase.updateRefs = true` (stacked branches), `diff.algorithm = histogram`,
`branch.sort = -committerdate`, `column.ui = auto`, `push.followTags`. Also:
there's no commit signing configured despite 1Password being available — wire
SSH commit signing or consciously leave it off; don't leave it half-intended.

**`alias cat="bat"`** (`dot_zshrc.tmpl:49`) — low risk (aliases skip scripts)
but `bat` injects decorations into interactive command substitutions/pipelines.
Consider keeping `cat` plain. Minor.

**`AppleKeyboardUIMode = 2`** (`macos-defaults.sh:47`) — the file's own comment
notes `3` = Full Keyboard Access (Tab reaches all controls). Decide `2` vs `3`
deliberately.

**`bash-version` branch** — looks stale (local + remote). Confirm it's not
needed and delete.

---

## Smaller things

- No network-inspection tool in the Brewfile (no Proxyman/Wireshark) — confirm
  that's intentional, not an oversight.
- Linux has no `LANG`/locale exports — watch for `setlocale` warnings over
  ssh/tmux; `glibc-langpack-en` (or re-adding `LANG`) is the fix if they appear.
- `tldr` + `hyperfine` are low-adoption keepers — fine, they're tiny.

---

## Suggested first move

The Mac side is basically done. To hit the goal, the work is:
**provisioning + Tailscale + a credential that outlives your SSH session + a
notification hook + a multiplexer choice.** Those turn "a Linux box" into
"agents I can trust while I'm asleep."

Start with one of:
- **provisioning + Tailscale** — so the box exists and is reachable, or
- **notification + credential layer** — so a box you already have becomes
  trustworthy unattended.

Quick decision-passes to settle: zellij vs. tmux, fnm vs. mise.
