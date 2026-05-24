# ── Powerlevel10k instant prompt (must stay near the top) ────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Oh My Zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7
zstyle ':omz:update' verbose silent

plugins=(
  git
  git-lfs
  gh
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  docker
  docker-compose
  node
  npm
  python
  rust
  brew
  macos
  vscode
  fzf
  colored-man-pages
  command-not-found
  sudo
  copybuffer
  copypath
  web-search
  encode64
)

source "$ZSH/oh-my-zsh.sh"

# ── PATH ─────────────────────────────────────────────────────────────────────
if [[ "$(uname -m)" == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

[[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]] && \
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# ── Language Managers ────────────────────────────────────────────────────────
eval "$(fnm env --use-on-cd)"
eval "$(uv generate-shell-completion zsh 2>/dev/null || true)"

# ── Tool Config ──────────────────────────────────────────────────────────────
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(direnv hook zsh)"

source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --reverse --border --preview "bat --style=numbers --color=always --line-range :500 {}"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export BAT_THEME="Dracula"
alias cat="bat"
alias less="bat --paging=always"

# ── Aliases ──────────────────────────────────────────────────────────────────

# List files (eza)
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first --git"
alias la="eza -a --icons"
alias lt="eza --tree --icons --level=2"
alias ltt="eza --tree --icons --level=3"

# Docker
alias d="docker"
alias dc="docker compose"
alias dex="docker exec -it"
alias drmi="docker rmi"
alias dprune="docker system prune -a"

# Python / uv
alias venv="uv venv && source .venv/bin/activate"
alias activate="source .venv/bin/activate"

# Misc
alias reload="source ~/.zshrc"
alias zshconfig="code ~/.zshrc"
alias hosts="sudo code /etc/hosts"
alias myip="curl -s ifconfig.me; echo"
alias localip="ipconfig getifaddr en0"
alias flushdns="sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo 'DNS flushed'"
alias cleanup="find . -name '.DS_Store' -delete"
alias brewup="brew update && brew upgrade && brew cleanup"
alias ports="sudo lsof -i -P -n | grep LISTEN"

# ── Functions ────────────────────────────────────────────────────────────────

y() {
  local tmp; tmp=$(mktemp -t "yazi-cwd.XXXXXX")
  yazi "$@" --cwd-file="$tmp"
  local cwd; cwd=$(cat -- "$tmp") && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && cd -- "$cwd"
  rm -f -- "$tmp"
}

gclone() { git clone "$1" && cd "$(basename "$1" .git)" || return; }

serve() { python3 -m http.server "${1:-8080}"; }

killport() {
  local pids; pids=$(lsof -ti tcp:"$1")
  [[ -n $pids ]] && kill -9 $pids || echo "No process on port $1"
}

whatsport() { sudo lsof -i :"$1"; }

extract() {
  if [ -f "$1" ]; then
    case $1 in
      *.tar.bz2) tar xjf "$1"    ;;
      *.tar.gz)  tar xzf "$1"    ;;
      *.tar.xz)  tar xJf "$1"    ;;
      *.bz2)     bunzip2 "$1"    ;;
      *.gz)      gunzip "$1"     ;;
      *.xz)      unxz "$1"       ;;
      *.tar)     tar xf "$1"     ;;
      *.tbz2)    tar xjf "$1"    ;;
      *.tgz)     tar xzf "$1"    ;;
      *.zip)     unzip "$1"      ;;
      *.Z)       uncompress "$1" ;;
      *)         echo "'$1' cannot be extracted (use Keka for .rar/.7z)" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

hist() { history | grep "$1"; }

weather() { curl "wttr.in/${1:-}"; }

jwt-decode() {
  jq -R 'split(".") | .[0],.[1] | @base64d | fromjson' <<< "$1"
}

# ── Environment ──────────────────────────────────────────────────────────────
export EDITOR="code --wait"
export VISUAL="$EDITOR"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export HISTSIZE=50000
export SAVEHIST=50000
export HIST_STAMPS="yyyy-mm-dd"

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

# ── Powerlevel10k config ─────────────────────────────────────────────────────
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ── Local overrides ──────────────────────────────────────────────────────────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
