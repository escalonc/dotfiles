---

1. Quick code/config fixes (low-risk, do anytime)

These came out of the file-by-file review. All small, all unambiguous.

┌───────────────────────────────┬──────────────────────┬───────────────────────────────────────────────────────────────────────────┐
│ Fix │ File │ Why │
├───────────────────────────────┼──────────────────────┼───────────────────────────────────────────────────────────────────────────┤
│ Drop the manual compinit │ dot_zshrc.tmpl:24-25 │ OMZ runs compinit itself — yours makes it run twice against two dump │
│ (keep fpath+=) │ │ files. Removing it achieves the goal your comment states. │
├───────────────────────────────┼──────────────────────┼───────────────────────────────────────────────────────────────────────────┤
│ Remove brew "zsh" │ Brewfile:6 │ Verified: your login shell is /bin/zsh (system). The Homebrew zsh is │
│ │ │ installed but never used on the Mac. │
├───────────────────────────────┼──────────────────────┼───────────────────────────────────────────────────────────────────────────┤
│ Set AppleKeyboardUIMode back │ macos-defaults.sh:47 │ You reverted Full Keyboard Access to the lesser mode and left a ⚠️ on it │
│ to 3 │ │ yourself. │
├───────────────────────────────┼──────────────────────┼───────────────────────────────────────────────────────────────────────────┤
│ Reconsider alias cat="bat" / │ dot_zshrc.tmpl:49-51 │ Footgun — trains muscle memory that breaks on boxes without bat. Prefer │
│ alias less │ │ catt="bat". (Preference.) │
├───────────────────────────────┼──────────────────────┼───────────────────────────────────────────────────────────────────────────┤
│ disable_root: true │ cloud-init.yaml:27 │ chris already has key auth + NOPASSWD sudo; the root key fallback is │
│ │ │ surface you don't need. │
└───────────────────────────────┴──────────────────────┴───────────────────────────────────────────────────────────────────────────┘

2. The agent-box architecture (the bigger calls)

Your use case clarified to "always-on box running coding agents I check on from my phone while away from the MacBook." That reframe
drove these:

- Stay on Hetzner — best price/performance for an always-on box; keep it.
- Switch to the ARM cax line (variables.tf server_type) — arm64 matches your Mac (cleaner Docker), and it's ~half the price of the
  equivalent x86 cpx. cax31 = same 8/16 as your current cpx41.
- Right-size down — agents are network-bound (they call the API; local CPU mostly idles). Start at cax21/cax31 and scale up only if
  builds demand it. You pay 24/7, so this matters.
- Tailscale is the headline (was a nice-to-have in turn 2, became the answer to "reach it while away"): install on box + phone/iPad,
  close public SSH entirely, tmux attach from Blink Shell anywhere. This replaces the brittle home-IP allowlist.
- Keep OpenTofu and the OpenTofu-for-infra / cloud-init→chezmoi-for-config split — don't add Ansible.
- Distro: lean Ubuntu LTS over Fedora for a rebuildable server (5-yr support, every cloud keeps current images, matches prod) — unless
  you specifically want Fedora's fresh packages. Real toss-up; Fedora's only real cost is the image-pin staleness you already flagged.
- Worth knowing, probably skip: Oracle Cloud Always Free (ARM Ampere, ~4 OCPU/24GB, $0/mo) is the genuine budget alternative — but
  account friction + reliability make Hetzner the "it just works" pick.

3. Tooling swaps (forward-looking, optional)

- Ghostty over Warp (top tool suggestion) — native, fast, plain-text config that lives in your dotfiles, no cloud account. Warp's
  account-synced config is at odds with your everything-reproducible ethos.
- mise over fnm — only once you go polyglot. mise replaces fnm+pyenv+asdf in one fast tool and does direnv-style env loading (which you
  removed direnv for). fnm is fine while it's Node-only.
- Zed — worth trying as an editor (fast, native, good remote-dev + AI). Your current Sublime + JetBrains + Claude-Code-over-SSH setup
  is already coherent, so this is low-priority.

4. Security for the always-on agent box

An autonomous-agent box reachable remotely is a real attack surface — worth doing from day one:

- Tailscale + closed public SSH (above) removes the internet-facing surface.
- Scoped credentials, not your whole identity — give the box a dedicated GitHub fine-grained PAT / deploy keys for only the repos it
  needs; be deliberate about what agent-forwarded 1Password keys can reach.
- Blast-radius limits — run agent work in git worktrees or containers; keep agents as non-root chris (you already do).

5. Keep as-is (so you don't second-guess)

The chezmoi architecture (templates + run_onchange with embedded hashes + .chezmoiexternal), the git config (rebase pulls, zdiff3,
rerere, delta, autoSetupRemote), the modern CLI stack (bat/eza/fd/fzf/ripgrep/zoxide/delta), OrbStack, and 1Password for agent+signing
— all genuinely well-chosen. Don't churn them.

6. Already in your REVIEW.md (your own open items, still valid)

SSH commit signing is unwired (dot_gitconfig.tmpl — wire or drop) · no network-inspection tool post-Proxyman · tmux + neovim configs
missing (these actually gate your "Claude Code in tmux" goal — highest-value of the three).

---

Suggested order if you want a path: §1 quick fixes now → §2 provisioning changes (ARM + Tailscale + tighter firewall) when you stand up
the box → tmux/nvim configs (from §6) before you rely on the box → §3 tooling swaps whenever.
