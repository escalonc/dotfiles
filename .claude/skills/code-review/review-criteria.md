# Review Criteria

Reference document for what each reviewer focuses on during `/code-review` in this repo.

## Repo Context

- Personal macOS dotfiles bootstrap; not a library, not a team project
- Entry: `bootstrap.sh` (curl|bash) → `setup.sh` → sources `scripts/*.sh` → symlinks `dotfiles/*` into `$HOME`
- Brewfile is declarative; `brew bundle` does the heavy lifting
- Target: macOS (Apple Silicon primary, Intel secondary), bash 3.2 minimum (system bash) and bash 5+ (Homebrew bash)
- User explicitly distrusts npm globals → pnpm is the default; npm is fallback only

## Claude Reviewer Focus

### Critical (block-the-merge)
- **Destructive overwrites of user state**: every modification to `~/.zshrc`, `~/.ssh/config`, `~/.gitconfig`, etc. needs a backup
- **Idempotency violations**: re-running setup.sh must not corrupt, duplicate, or escalate state (multiple keepalive processes, accumulating backup files, drifting Node versions)
- **Broken fail-fast**: `set -e`, `set -u`, and `pipefail` interactions with sourced scripts; the boundary between bootstrap.sh (`-e` on) and setup.sh (`-e` off) is intentional — flag if it's accidentally inverted
- **Cross-file ordering**: a sourced script's prereq must exist by the time it runs (e.g. `pnpm` after Brewfile, `fnm env` after fnm install, PNPM_HOME before `pnpm add -g`)
- **Symlink hazards**: `ln -sf` vs `ln -sfn` on macOS BSD (the `-n` flag matters when the destination is a symlink-to-directory)
- **Tee + process substitution**: `exec > >(tee ...)` interactions with `read`, prompt buffering, double-logging when nested

### Important
- **Brewfile / cask quirks**: missing entries, taps required, casks needing kext approval (wireshark, orbstack)
- **Tool-version drift**: alias names that change across versions (fnm `lts-latest` vs `lts/<codename>`)
- **Sudo keepalive**: the loop must be cleaned up via `trap` on EXIT/INT/TERM; orphan loops refresh sudo past intended scope
- **Logging hygiene**: `2>>$LOG_FILE` inside a script that already `exec > >(tee ...)` either races or hides stderr from the terminal
- **Manual post-install steps**: documented in the final summary; don't silently require things

### Minor
- Comment hygiene (no narration of obvious code)
- Naming consistency (`info`/`success`/`warn`/`error` from helpers.sh)
- Defensive `|| true` chains — sometimes mask the actual bug

### Positive
- Effective use of helpers (`section`, `info`, `success`, `error`)
- Genuine idempotency (guards before destructive ops, backups before overwrites)
- Clean separation between curlable bootstrap and the orchestrator

## Codex Focus (when available)

- **Alternative shell idioms** the Claude pass may miss (associative arrays, parameter expansion tricks)
- **Cross-script consistency** with patterns already used elsewhere in this repo
- **Algorithmic correctness** of any non-trivial logic (e.g. brew bundle check output parsing)

## Severity Definitions

| Level | When to use |
|---|---|
| **Critical** | Destructive ops without backup, broken idempotency, security issues, fail-fast removed inappropriately |
| **Important** | Cross-file ordering issues, tool-version assumptions, logging/redirect mistakes, missing error tracking |
| **Minor** | Style, comment hygiene, naming, defensive `|| true` masking real failures |
| **Positive** | Patterns worth reinforcing — good guards, clean abstractions, careful logging |
