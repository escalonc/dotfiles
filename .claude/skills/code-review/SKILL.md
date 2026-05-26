---
name: code-review
description: Code Review — use when the user runs /code-review or asks for a code review. Gates on diff threshold, runs Claude + Codex reviewers in parallel, then validates shell scripts with bash -n / shellcheck.
version: 1.0.0
---

# Code Review Skill (dotfiles)

This pipeline reviews shell-script + Brewfile + dotfile changes in this repo. Two reviewers run in parallel (Claude + Codex when available), then the diff is validated for syntax and (when shellcheck is installed) for lint issues.

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

(Thresholds are lower than the .NET monorepo's because this repo is small and a 10-line shell change can still introduce real bugs — but trivial README touches don't need the full pipeline.)

## Step 2: Check Available Tools

Run these in parallel:

```bash
command -v codex >/dev/null 2>&1 && echo "CODEX_AVAILABLE" || echo "CODEX_MISSING"
command -v shellcheck >/dev/null 2>&1 && echo "SHELLCHECK_AVAILABLE" || echo "SHELLCHECK_MISSING"
```

(Use `command -v` rather than running the binary and piping through `head` — without `pipefail` set, a missing binary can produce a misleading "available" because `head` exits 0 on empty input.)

Note which are available — affects Step 3 and Step 5.

## Step 3: Launch Reviewers in Parallel

In a **single message**, launch all available reviewers using the Agent tool — they must run simultaneously, not sequentially.

### Always launch:

**Agent 1 — Claude Reviewer** (`general-purpose` subagent type)

Prompt:
```
You are reviewing shell-script changes in /Users/chris/Source/dotfiles. Run `git diff main...HEAD` (fall back to `git diff HEAD` if the range is empty) to get the scope.

Read every modified file in full — don't review from the diff alone. The setup flow is:
  bootstrap.sh → setup.sh → scripts/*.sh (sourced in order) → dotfiles/* (symlinked into $HOME)

Reference review criteria at .claude/skills/code-review/review-criteria.md.

Focus on:
- Bash pitfalls (set -e/-u/pipefail interactions, word splitting, unquoted vars, command substitution failures, sourced vs spawned exit semantics)
- Idempotency (re-running setup.sh must not be destructive)
- Cross-file ordering (sourced scripts share PATH/env — does each script's prereq exist when sourced?)
- Destructive operations on user state (~/.zshrc, ~/.ssh/config, ~/.gitconfig) — every overwrite needs a backup
- macOS specifics (BSD vs GNU tool flags, system Python/bash versions, defaults write keys)
- Brewfile / cask / fnm / pnpm / uv quirks
- Logging correctness (tee/exec/process-substitution gotchas)
- Trap and signal handling (sudo keepalive, background process cleanup)

Output structured feedback with severity levels: Critical / Important / Minor / Positive. For each finding cite file:line and a concrete failure scenario.
```

### Launch if codex is available:

**Agent 2 — Codex Review** (`general-purpose` subagent type)

Prompt:
```
Run the following command from /Users/chris/Source/dotfiles and return its full stdout output as your result:

codex exec "Review the recent git changes (git diff main...HEAD, fall back to git diff HEAD if empty) for code quality, potential bugs, security issues, design problems, and shell-script footguns. The repo is a personal macOS dotfiles bootstrap: bootstrap.sh, setup.sh, scripts/*.sh, Brewfile, dotfiles/.zshrc, dotfiles/.ssh/config. Focus on bash pitfalls, idempotency, destructive ops on user state, macOS specifics, and cross-script ordering. Output structured feedback with severity levels: Critical / Important / Minor." --sandbox read-only --skip-git-repo-check

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

When both reviewers flag the same issue, list it once with both citations. When they disagree, surface both views — Claude's strength is cross-file tracing and bash semantics; Codex's strength is alternative idioms and catching things a Claude pass missed.

## Step 5: Validate Shell Scripts

After the review report is presented, validate the changed scripts.

1. **List changed shell files**:
```bash
git diff --name-only main...HEAD | grep -E '\.(sh|zsh|bash)$' || git diff --name-only HEAD | grep -E '\.(sh|zsh|bash)$'
```

Also include the unchanged scripts they depend on (transitive sourcing).

2. **Syntax check** — always runs, no install needed:
```bash
for f in <changed_scripts>; do bash -n "$f" && echo "✓ $f" || echo "✗ $f"; done
```

3. **Shellcheck** — only if available:
```bash
shellcheck -x -s bash <changed_scripts>
```
The `-x` flag follows `source` statements so cross-file issues surface.

4. **Handle failures**: If `bash -n` fails, that's a hard error — fix and re-run. Shellcheck warnings are informational; fix Critical/Important findings, leave style ones unless the user asks.

## Step 6: Final Summary

Append validation results to the review report:

```
### 🧪 Validation
- bash -n: <pass/fail counts>
- shellcheck: <pass/fail counts, or "not installed">
- Scripts checked: <list>

### 📊 Summary
- Reviewers run: <list>
- Files reviewed: <count>
- Total review issues found: <Critical / Important / Minor counts>
- Validation: <pass/fail>
```

If a reviewer or validation step was skipped (codex/shellcheck not installed, no shell files in diff), note it under Summary.
