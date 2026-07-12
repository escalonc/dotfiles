# ═══════════════════════════════════════════════════════════════════════════
# "Ink" — Powerlevel10k × Monokai Pro Spectrum
# Pure typography: no pills, no backgrounds. Hierarchy from weight + dimming.
#   place = orange · ok/clean = green · error/conflict = red · dirty git = yellow
#   duration & vi command mode = purple · detail/meta = grays
#
# HOW TO APPLY
#   1. Save this file as ~/.config/zsh/p10k-ink.zsh  (or anywhere you like)
#   2. In ~/.zshrc, AFTER the line that sources ~/.p10k.zsh, add:
#        source ~/.config/zsh/p10k-ink.zsh
#   3. Open a new terminal (or run: p10k reload)
#
# Branch icon uses the Powerline glyph  (" main") — needs a Nerd Font
# (or Ghostty, which bundles the symbols as a built-in fallback).
# Ghostty renders the truecolor hexes.
# ═══════════════════════════════════════════════════════════════════════════

# Anonymous function scope: keeps the palette locals below from leaking into
# the interactive shell (typeset -g settings are global regardless).
() {
emulate -L zsh -o extended_glob

# ── Monokai Pro Spectrum palette ──────────────────────────────────────────────────────
local muted='#8b888f'    # secondary text
local dim='#69676c'      # timestamps, meta
local orange='#fd9353'   # place (dir anchor)
local red='#fc618d'      # error / conflict
local green='#7bd88f'    # ok / clean
local yellow='#fce566'   # dirty git
local purple='#948ae3'   # duration, vi command mode

# ── Layout: dir + git on top, prompt char below; status + time on the right ──
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs newline prompt_char)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs context time)

# ── Kill the pills: transparent everywhere, no powerline separators ──────────
typeset -g POWERLEVEL9K_BACKGROUND=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_PROMPT_{FIRST,LAST}_SEGMENT_{START,END}_SYMBOL=

# Blank line between prompts; no connector frame on the two-line prompt
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
typeset -g POWERLEVEL9K_MULTILINE_{FIRST,NEWLINE,LAST}_PROMPT_PREFIX=
typeset -g POWERLEVEL9K_MULTILINE_{FIRST,NEWLINE,LAST}_PROMPT_SUFFIX=' '

# ── Directory: dimmed path, bold orange current dir ─────────────────────────
# Rule: the deepest displayed path element is orange, everything before it is
# muted. PATH_HIGHLIGHT styles exactly the last element — so a lone ~ at home
# is orange with no special-casing. (Customizing HOME_FOLDER_ABBREVIATION is a
# trap: p10k strips the element's internal anchor marker, excluding it from
# anchor/highlight styling entirely.)
typeset -g POWERLEVEL9K_DIR_FOREGROUND=$muted
typeset -g POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND=$orange
typeset -g POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD=true
# Neutralize the lean base's anchor color: first element and repo roots would
# otherwise render orange mid-path. They stay anchors, so repo-root names keep
# their protection from truncation — just muted like the rest of the path.
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$muted
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=false
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=$dim
# At / p10k renders only the path separator — there is no last element to
# style. Express the same rule via location classes: at the filesystem root
# the whole segment IS the current dir, so the whole segment goes orange.
typeset -g POWERLEVEL9K_DIR_CLASSES=('/' ROOT '' '*' '' '')
typeset -g POWERLEVEL9K_DIR_ROOT{,_NOT_WRITABLE}_FOREGROUND=$orange
typeset -g POWERLEVEL9K_DIR_ROOT{,_NOT_WRITABLE}_CONTENT_EXPANSION='%B${P9K_CONTENT}'
typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION=   # no folder/OS icon

# ── Git: green when clean, pink when dirty; counts bold ─────────────────────
function my_git_formatter() {
  emulate -L zsh
  if [[ -n $P9K_CONTENT ]]; then
    typeset -g my_git_format=$P9K_CONTENT   # prompt in progress: keep as-is
    return
  fi

  local green='%F{#7bd88f}' yellow='%F{#fce566}' red='%F{#fc618d}' dim='%F{#69676c}'
  local meta=$dim clean=$green modified=$yellow untracked=$yellow conflicted=$red

  # dirty repo → branch name goes yellow too (whole segment reads as one state)
  if (( VCS_STATUS_NUM_CONFLICTED || VCS_STATUS_NUM_STAGED ||
        VCS_STATUS_NUM_UNSTAGED   || VCS_STATUS_NUM_UNTRACKED )); then
    clean=$yellow
  fi

  local res
  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
    local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
    (( $#branch > 32 )) && branch[13,-13]="…"
    res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
  fi
  if [[ -n $VCS_STATUS_TAG && -z $VCS_STATUS_LOCAL_BRANCH ]]; then
    res+="${meta}#${clean}${(V)VCS_STATUS_TAG//\%/%%}"
  fi
  [[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] &&
    res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"
  if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
    res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
  fi
  (( VCS_STATUS_COMMITS_AHEAD  )) && res+=" ${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
  (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
  (( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
  [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
  (( VCS_STATUS_NUM_CONFLICTED )) && res+=" %B${conflicted}~${VCS_STATUS_NUM_CONFLICTED}%b"
  (( VCS_STATUS_NUM_STAGED     )) && res+=" %B${modified}+${VCS_STATUS_NUM_STAGED}%b"
  (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" %B${modified}!${VCS_STATUS_NUM_UNSTAGED}%b"
  (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" %B${untracked}?${VCS_STATUS_NUM_UNTRACKED}%b"
  (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}─"

  typeset -g my_git_format=$res
}
functions -M my_git_formatter 2>/dev/null

typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter()))+${my_git_format}}'
typeset -g POWERLEVEL9K_VCS_{CLEAN,MODIFIED,UNTRACKED}_FOREGROUND=$green
typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=   # icon handled in formatter
typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '  # Powerline branch glyph
typeset -g POWERLEVEL9K_VCS_PREFIX=

# ── Prompt char: ❯ inherits last exit code ──────────────────────────────────
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VIVIS,VIOWR}_FOREGROUND=$green
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VIVIS,VIOWR}_FOREGROUND=$red
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_FOREGROUND=$purple
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'

# ── Right side: ✗ 1 only on error, dim timestamp ─────────────────────────────
typeset -g POWERLEVEL9K_STATUS_OK=false
typeset -g POWERLEVEL9K_STATUS_OK_PIPE=false
typeset -g POWERLEVEL9K_STATUS_ERROR=true
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=$red
typeset -g POWERLEVEL9K_STATUS_ERROR_CONTENT_EXPANSION='%B${P9K_CONTENT}%b'
typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='%B✗%b'
typeset -g POWERLEVEL9K_STATUS_{ERROR_PIPE,ERROR_SIGNAL}_FOREGROUND=$red

# Duration of the last command, shown once it finishes (only if it took >3s)
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$purple
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX=
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_CONTENT_EXPANSION='%B${P9K_CONTENT}%b'
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION=

typeset -g POWERLEVEL9K_TIME_FOREGROUND=$dim
typeset -g POWERLEVEL9K_TIME_PREFIX=
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%I:%M:%S %p}'
typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

# ── Everything else p10k may print: same ink treatment ──────────────────────
# Background jobs: yellow &N
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=$yellow
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=true
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_CONTENT_EXPANSION='&${P9K_CONTENT}'

# user@host: hidden locally, muted over ssh, red when root
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=$muted
typeset -g POWERLEVEL9K_CONTEXT_{ROOT,REMOTE_SUDO}_FOREGROUND=$red
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
typeset -g POWERLEVEL9K_CONTEXT_VISUAL_IDENTIFIER_EXPANSION=

# Non-writable dir: drop the Nerd Font padlock (would render as tofu)
typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=

}

# Reload only when this file is re-sourced by hand — on shell startup the theme
# hasn't rendered yet, so reloading would just slow down init.
if (( ${+__p10k_ink_loaded} )); then
  (( $+functions[p10k] )) && p10k reload
fi
typeset -g __p10k_ink_loaded=1
