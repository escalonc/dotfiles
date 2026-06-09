{{- /*
  Shared shell prelude for run_* scripts.

  chezmoi runs each run_* script as its OWN process, so any PATH / env a script
  sets up is INVISIBLE to the next script. Every script that uses tools installed
  outside the system package manager (fnm-managed Node, pnpm, things dropped in
  ~/.local/bin) must re-establish them itself.

  Instead of copy-pasting that setup into each script, include this once, right
  after `set -euo pipefail`:

      {{ template "dev-env.sh" . }}

  Edit the environment contract HERE and every script picks it up (and re-runs,
  since changing this changes their rendered content).
*/ -}}
# --- shared dev environment (see .chezmoitemplates/dev-env.sh) ---
# User-local binaries installed outside a package manager (fnm, pnpm, atuin, …).
export PATH="$HOME/.local/bin:$PATH"

# Node, via fnm, if present — puts `node`/`npm` on PATH for anything that needs them.
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env)"
fi
