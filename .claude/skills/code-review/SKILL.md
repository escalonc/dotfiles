---
name: code-review
description: Code Review — use when the user runs /code-review or asks for a code review. Gates on diff threshold, runs Claude + Codex reviewers in parallel, then validates shell scripts (rendering chezmoi templates first) and the OpenTofu config.
version: 2.0.0
---

# Code Review Skill (dotfiles)

This pipeline reviews changes to a **chezmoi-managed, multi-machine dotfiles repo**: `run_onchange_*.sh.tmpl` provisioning scripts, `dot_*` file templates, the Brewfile, and the `provisioning/` OpenTofu config. Two reviewers run in parallel (Claude + Codex when available), then changed scripts are validated — chezmoi templates are rendered before linting, since raw `.tmpl` files are not valid bash.

## Step 1: Anti-Loop Gate

Before doing anything else, run:

```bash
git diff main...HEAD --numstat
```

If `main...HEAD` has no divergence (you're on `main`), use this priority:

1. **Uncommitted work** if there is any: `git diff HEAD --numstat`
2. **Otherwise the last commit** (so a /code-review after `git commit && git push` still reviews the commit it's meant to): `git diff HEAD~1..HEAD --numstat`

Parse the output:
- Count the number of lines (= number of files changed)
- Sum the first two columns (insertions + deletions) across all lines = total lines changed
- For binary files `--numstat` emits `-` in place of the counts — treat `-` as `0` when summing

**If fewer than 2 files changed AND fewer than 20 total lines changed → print "No significant changes to review, skipping." and stop immediately.** Do not launch any agents.

(Thresholds are low because this repo is small and a 10-line shell change can still introduce real bugs — but trivial README touches don't need the full pipeline.)

## Step 2: Check Available Tools

Run these in parallel:

```bash
command -v codex >/dev/null 2>&1 && echo "CODEX_AVAILABLE" || echo "CODEX_MISSING"
command -v shellcheck >/dev/null 2>&1 && echo "SHELLCHECK_AVAILABLE" || echo "SHELLCHECK_MISSING"
command -v chezmoi >/dev/null 2>&1 && echo "CHEZMOI_AVAILABLE" || echo "CHEZMOI_MISSING"
command -v tofu >/dev/null 2>&1 && echo "TOFU_AVAILABLE" || echo "TOFU_MISSING"
```

(Use `command -v` rather than running the binary and piping through `head` — without `pipefail` set, a missing binary can produce a misleading "available" because `head` exits 0 on empty input.)

Note which are available — affects Step 3 and Step 5.

## Step 3: Launch Reviewers in Parallel

In a **single message**, launch all available reviewers using the Agent tool — they must run simultaneously, not sequentially.

### Always launch:

**Agent 1 — Claude Reviewer** (`general-purpose` subagent type)

Prompt:
```
You are reviewing changes in /Users/chris/Source/dotfiles, a chezmoi-managed dotfiles repo targeting TWO machines: a macOS Apple Silicon workstation and a headless Fedora Linux server. Run `git diff main...HEAD` (fall back to `git diff HEAD` if the range is empty) to get the scope.

Read every modified file in full — don't review from the diff alone. Architecture facts you must reason with:
- `chezmoi init --apply` runs numbered `run_onchange_before_*` scripts, applies `dot_*` templates into $HOME, then runs `run_onchange_after_*` scripts.
- EACH run script is its OWN process — env/PATH set in one script is invisible to the next. Each script re-establishes the environment inline (brew on macOS, `~/.local/bin` on Linux).
- `.tmpl` files are Go templates branching on `.chezmoi.os` ("darwin"/"linux") and the `headless` flag (defined in .chezmoi.toml.tmpl; defaults true when no TTY, e.g. under cloud-init).
- `run_onchange_*` scripts re-run when their RENDERED content changes (the Brewfile hash embedded in the `system` script exists for exactly this) and must be idempotent.
- `provisioning/` is OpenTofu for the Hetzner box: machine only; software comes from cloud-init.yaml → chezmoi. Changing user_data (cloud-init.yaml) forces destroy+recreate; the server has prevent_destroy = true as a guard.

Reference review criteria at .claude/skills/code-review/review-criteria.md.

Focus on:
- Bash pitfalls (set -e/-u/pipefail interactions, word splitting, command substitution failures) AND zsh-specific pitfalls in dot_zshrc (zsh does NOT word-split unquoted parameters)
- Per-process environment assumptions (does a script assume PATH/env from an earlier script? does it include the dev-env prelude when it needs brew/fnm/pnpm/~/.local/bin?)
- Template branch coverage: does every `{{ if }}` chain handle darwin, linux, AND the else case? Is a feature gated on `headless` vs OS correctly?
- Fresh-machine behavior: would this work on a pristine Mac (no Homebrew on PATH) and on first boot of the Fedora box (non-interactive, no TTY)?
- Idempotency of run_onchange scripts (re-runs must not duplicate or destroy state)
- Supply-chain: release binaries must be version-pinned with sha256 verified; flag any new unpinned `curl | bash` beyond the accepted vendor installers (Homebrew, chezmoi, Oh My Zsh, fnm, pnpm, Claude)
- macOS specifics (BSD vs GNU flags, `defaults write` keys, TCC-protected domains) and Fedora specifics (dnf package names, packages absent from cloud images)
- provisioning/: tofu resource semantics (what forces replacement?), cloud-init YAML validity (placeholders, quoting), firewall/secrets handling
- Trap and signal handling (sudo keepalive, RETURN traps, background process cleanup)

Output structured feedback with severity levels: Critical / Important / Minor / Positive. For each finding cite file:line and a concrete failure scenario.
```

### Launch if codex is available:

**Agent 2 — Codex Review** (`general-purpose` subagent type)

Prompt:
```
Run the following command from /Users/chris/Source/dotfiles and return its full stdout output as your result:

codex exec "Review the recent git changes (git diff main...HEAD, fall back to git diff HEAD if empty) for code quality, potential bugs, security issues, design problems, and shell-script footguns. The repo is a chezmoi-managed personal dotfiles repo for two machines (macOS Apple Silicon + headless Fedora server): run_onchange_*.sh.tmpl provisioning scripts (Go templates branching on .chezmoi.os and a headless flag; each script runs as its own process), dot_* templates, Brewfile, and provisioning/ (OpenTofu + cloud-init for a Hetzner box). Focus on bash/zsh pitfalls, idempotency of run_onchange scripts, per-process environment assumptions, template branch coverage, fresh-machine behavior, supply-chain pinning, and tofu/cloud-init semantics. Output structured feedback with severity levels: Critical / Important / Minor." --sandbox read-only --skip-git-repo-check

If the command fails or codex is not available, include the stderr output and say "Codex review unavailable: <reason>".
```

## Step 4: Consolidate Review Results

After all agents complete, produce a unified report:

```
## Code Review Report

### 🔴 Critical
<issues from any reviewer — destructive ops, security, broken idempotency, correctness bugs>

### 🟠 Important
<significant quality, performance, or design concerns>

### 🟡 Minor
<style, clarity, minor improvements>

### ✅ Positive
<good implementations worth highlighting>
```

When both reviewers flag the same issue, list it once with both citations. When they disagree, surface both views — Claude's strength is cross-file tracing and bash/template semantics; Codex's strength is alternative idioms and catching things a Claude pass missed.

## Step 5: Validate Changed Files

After the review report is presented, validate the changed files.

1. **List changed shell files — the pattern MUST include `.sh.tmpl`** (this repo's run scripts are all templates; a plain `\.sh$` filter would silently match nothing):

```bash
git diff --name-only main...HEAD | grep -E '\.(sh|zsh|bash)$|\.sh\.tmpl$'
```

(Use the same fallback scope as Step 1 if the range is empty.) Also include any `.chezmoitemplates/*` file in the set whenever a script that includes it (via `{{ template ... }}`) changed.

2. **Plain `.sh` files** — check directly:

```bash
bash -n <file> && shellcheck -x -s bash <file>
```

3. **`.sh.tmpl` files** — raw templates are NOT valid bash; render first.
   - If chezmoi is available, render with this machine's data, then check the result:
     ```bash
     chezmoi execute-template < <file> > /tmp/rendered.sh
     bash -n /tmp/rendered.sh && shellcheck -S warning -s bash /tmp/rendered.sh
     ```
     **Caveat:** this renders only the CURRENT machine's branch (e.g. darwin). Note in the summary which OS branch went unvalidated.
   - If chezmoi is missing, do not skip silently: say so in the summary, and at minimum eyeball-review the non-current-OS branches in the diff.

4. **provisioning/ changes** — if any `*.tf` or `cloud-init.yaml` changed and tofu is available:

```bash
cd provisioning && tofu init -backend=false -input=false >/dev/null && tofu validate
```

Also sanity-parse `cloud-init.yaml` as YAML if a parser is available (`ruby -ryaml -e 'YAML.load_file("provisioning/cloud-init.yaml")'`).

5. **Handle failures**: If `bash -n` or `tofu validate` fails, that's a hard error — fix and re-run. Shellcheck warnings are informational; fix Critical/Important findings, leave style ones unless the user asks.

## Step 6: Final Summary

Append validation results to the review report:

```
### 🧪 Validation
- bash -n: <pass/fail counts>
- shellcheck: <pass/fail counts, or "not installed">
- templates rendered: <count, and which OS branch>; branches NOT validated: <list or "none">
- tofu validate: <pass/fail, or "no provisioning changes" / "tofu not installed">
- Files checked: <list>

### 📊 Summary
- Reviewers run: <list>
- Files reviewed: <count>
- Total review issues found: <Critical / Important / Minor counts>
- Validation: <pass/fail>
```

If a reviewer or validation step was skipped (codex/shellcheck/chezmoi/tofu not installed, no matching files in diff), note it explicitly under Summary — never let a skipped check read as a passed check.
