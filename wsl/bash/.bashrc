# ~/.bashrc - Bootstrap Loader (Clean & Fast)
# Author : Rvkt
# Focus  : Git-aware prompt, modular config, fast startup

# Exit if not interactive
case $- in
    *i*) ;;
      *) return;;
esac


# =======================================================
# 0. GLOBAL SETUP
# =======================================================
export DOTFILES="$HOME/.dotfiles"
export DOTFILES_DEBUG="${DOTFILES_DEBUG:-0}"
export EDITOR="vim"
export VISUAL="vim"


log_debug() {
  [ "$DOTFILES_DEBUG" = "1" ] && echo "[DEBUG] $1"
}


# =======================================================
# 1. CORE LOADER FUNCTIONS
# =======================================================
safe_source() {
  local file="$1"
  if [ -r "$file" ]; then
    log_debug "Loading $(basename "$file")"
    source "$file"
  fi
}


load_folder() {
  local path="$1"
  local label="$2"

  if [ ! -d "$path" ]; then
    log_debug "$label directory not found: $path"
    return
  fi

  for file in "$path"/*.sh; do
    [ -r "$file" ] || continue
    log_debug "Loading $label: $(basename "$file")"
    source "$file"
  done
}


# =======================================================
# 2. HISTORY
# =======================================================
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend checkwinsize


# =======================================================
# 3. PROMPT — Git-Aware
# =======================================================

# Load official git-prompt (ships with git)
safe_source "/usr/lib/git-core/git-prompt.sh"

# Git status indicators
export GIT_PS1_SHOWDIRTYSTATE=1      # * unstaged  + staged
export GIT_PS1_SHOWSTASHSTATE=1      # $ stashed
export GIT_PS1_SHOWUNTRACKEDFILES=1  # % untracked
export GIT_PS1_SHOWCOLORHINTS=1      # colored branch name

# Colors
_CLR_GREEN='\[\033[01;32m\]'
_CLR_BLUE='\[\033[01;34m\]'
_CLR_YELLOW='\[\033[0;33m\]'
_CLR_RESET='\[\033[00m\]'

# Dir: uppercase basename, empty at home
__prompt_dir() {
  if [ "$PWD" = "$HOME" ]; then
    echo ""
  else
    local d="${PWD##*/}"
    echo ":${d^^}"
  fi
}

PS1="${_CLR_GREEN}Rvkt${_CLR_RESET}"'$(__prompt_dir)'"${_CLR_YELLOW}"'$(__git_ps1 " (%s)")'"${_CLR_RESET}"'\$ '

# History sync — runs every prompt, separate from PS1 logic
PROMPT_COMMAND="history -a; history -c; history -r"


# =======================================================
# 4. GIT ALIASES
# =======================================================
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit --amend --no-edit'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch -vv'
alias gbd='git branch -d'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate --all'
alias gst='git stash'
alias gstp='git stash pop'
alias grh='git reset --hard'
alias grs='git restore --staged'
alias gclean='git clean -fd'


# =======================================================
# 5. GIT SYMLINK — Self-Healing
# =======================================================
GIT_TARGET="$DOTFILES/shared/git/.gitconfig"

if [ ! -L "$HOME/.gitconfig" ] || \
   [ "$(readlink "$HOME/.gitconfig" 2>/dev/null)" != "$GIT_TARGET" ]; then
  rm -f "$HOME/.gitconfig"
  ln -s "$GIT_TARGET" "$HOME/.gitconfig"
  log_debug "Fixed git symlink → $GIT_TARGET"
fi


# =======================================================
# 6. MODULAR CONFIG
# =======================================================
load_folder "$DOTFILES/wsl/bash/scripts"   "script"
load_folder "$DOTFILES/wsl/bash/functions" "function"


# =======================================================
# 7. BASH COMPLETION
# =======================================================
if [ -f /usr/share/bash-completion/bash_completion ]; then
  source /usr/share/bash-completion/bash_completion
fi