# Ink prompt, right-side ✔/✗: starship's [status] module can't show ✔ on
# success without also printing the raw exit code, so this precmd formats the
# status for the [env_var.INK_*] modules in starship.toml. It must run AFTER
# starship's precmd (which saves $? into STARSHIP_CMD_STATUS before anything
# else can clobber it) — .zshrc sources this file right below the starship
# init line for that reason.
_ink_status() {
  unset INK_OK INK_ERR
  [[ -v STARSHIP_CMD_STATUS ]] || return 0   # fresh prompt, nothing ran yet
  local code=$STARSHIP_CMD_STATUS err=''
  local -a pipe=("${(@)STARSHIP_PIPE_STATUS}")
  if (( ${#pipe} > 1 )) && [[ "${pipe[*]}" == *[1-9]* ]]; then
    err="${(j:|:)pipe}"                      # failed pipeline: code per command
  elif (( code > 128 && code < 193 )); then
    err="$(builtin kill -l $(( code - 128 )) 2>/dev/null)"   # signal name (INT…)
    [[ -n $err ]] || err=$code
  elif (( code != 0 )); then
    err=$code
  fi
  if [[ -n $err ]]; then export INK_ERR=$err; else export INK_OK='✔'; fi
  return 0
}
# (Ie) exact-match guard: don't register twice if this file is re-sourced
(( ${precmd_functions[(Ie)_ink_status]} )) || precmd_functions+=(_ink_status)
