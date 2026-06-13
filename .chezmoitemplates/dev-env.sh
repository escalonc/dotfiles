{{- /*
  Shared env prelude — each run_* script is its OWN process, so env set by one
  is invisible to the next. Include right after `set -euo pipefail`:

      {{ template "dev-env.sh" . }}

  Editing this re-renders (and re-runs) every including script.
*/ -}}
# --- shared dev environment (see .chezmoitemplates/dev-env.sh) ---
export PATH="$HOME/.local/bin:$PATH"

# A fresh Mac's PATH lacks /opt/homebrew/bin, and scripts inherit the invoking
# shell's PATH — brew (and everything it installed) must be re-established here.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env)"
fi
