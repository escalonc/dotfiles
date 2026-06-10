# Review Criteria

Reference document for what each reviewer focuses on during `/code-review` in this repo.

## Repo Context

- Personal dotfiles repo; not a library, not a team project
- Managed by chezmoi: `chezmoi init --apply` runs numbered `run_onchange_before_*` scripts, applies `dot_*` templates into `$HOME`, then runs `run_onchange_after_*` scripts
- **Two target machines**: macOS Apple Silicon workstation (`/opt/homebrew`) and a headless Fedora Linux server (Hetzner, created by `provisioning/` OpenTofu + cloud-init). Templates branch on `.chezmoi.os` and the `headless` flag — never on hostnames
- **Each run script is its own process** — env/PATH does not carry between scripts. The shared prelude `.chezmoitemplates/dev-env.sh` re-establishes `~/.local/bin`, Homebrew, and fnm; scripts that need those tools must include it
- `run_onchange_*` scripts re-run whenever their rendered content changes (the Brewfile hash embedded in 10-packages exists for this) and must be idempotent
- Brewfile is declarative for macOS; Fedora uses an inline `dnf` list plus pinned, checksum-verified release binaries into `~/.local/bin`
- User explicitly distrusts npm globals → pnpm is the default; npm is fallback only
- Accepted supply-chain tradeoff: vendor `curl | bash` installers (Homebrew, chezmoi, Oh My Zsh, fnm, pnpm, Claude Code) are allowed; **anything else must be version-pinned with a sha256 recorded in the repo**

## Claude Reviewer Focus

### Critical (block-the-merge)
- **Fresh-machine failures**: would this work on a pristine Mac (default PATH has no `/opt/homebrew/bin`) and on the Fedora box's first boot (non-interactive, no TTY, `headless=true`)? Any script assuming env from an earlier script is a bug — check for the dev-env prelude
- **Idempotency violations**: re-running `chezmoi apply` must not corrupt, duplicate, or escalate state (multiple keepalive processes, duplicate PATH entries, re-downloading over existing installs)
- **Template branch coverage**: every `{{ if }}` chain must handle darwin, linux, and fall through safely (`exit 0`) elsewhere; features gated on `headless` vs OS for the right reason (GUI-ness → headless; package manager → OS)
- **Destructive operations**: anything that can delete user state — including `tofu apply` replacement semantics (user_data changes destroy the server; `prevent_destroy = true` must stay unless deliberately flipped)
- **zsh vs bash semantics in dotfiles**: `dot_zshrc.tmpl` runs under zsh — no word-splitting of unquoted parameters (use `${(f)var}` etc.); run scripts are bash — opposite rules
- **Secrets**: no tokens/keys in committed files; `TF_VAR_*` env vars only; tfstate/tfvars stay gitignored

### Important
- **Supply-chain pinning**: new release-binary downloads must pin version + verify sha256 (see `dl_tarbin` in 10-packages); flag unpinned `latest` URLs
- **Brewfile / dnf quirks**: missing entries, formula renames, packages absent from Fedora cloud images; tools referenced by `dot_zshrc` aliases/functions must exist on BOTH machines or be guarded
- **Sudo handling**: keepalive loops cleaned up via `trap`; `sudo -n` probes before optional sudo work; cloud-init runs with NOPASSWD but interactive Linux may not
- **Tool-version drift**: alias names that change across versions (fnm `lts-latest`), Hetzner image names going stale (`fedora-NN`)
- **`set -e` discipline**: before-scripts use `set -euo pipefail`; 60/70 deliberately omit `-e` (best-effort `defaults write` / installer fallbacks) — flag if that inverts
- **Manual post-install steps**: documented in the README; don't silently require things

### Minor
- Comment hygiene (comments state constraints, not narration; this repo's bar is high — keep it)
- Guard consistency (tool inits and aliases in dot_zshrc are `command -v`-guarded — new ones should be too)
- Defensive `|| true` chains — sometimes mask the actual bug

### Positive
- Genuine idempotency (guards before destructive ops, `clone_if_missing`-style helpers)
- Correct use of the dev-env prelude instead of copy-pasted PATH setup
- Re-run triggers done right (content hashes embedded in rendered scripts)
- Fail-closed defaults (`ssh_allowed_ips` has no default; validation blocks empty)

## Codex Focus (when available)

- **Alternative shell idioms** the Claude pass may miss (associative arrays, parameter expansion tricks)
- **Cross-script consistency** with patterns already used elsewhere in this repo
- **Algorithmic correctness** of any non-trivial logic (checksum verification flow, tarball extraction, template conditionals)

## Severity Definitions

| Level | When to use |
|---|---|
| **Critical** | Fresh-machine breakage, destructive ops without a guard, broken idempotency, security/secret issues, wrong template branch |
| **Important** | Cross-script env assumptions, unpinned downloads, tool-version assumptions, missing OS-branch handling |
| **Minor** | Style, comment hygiene, naming, defensive `|| true` masking real failures |
| **Positive** | Patterns worth reinforcing — good guards, prelude reuse, fail-closed defaults |
