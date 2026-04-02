# ~/.bashrc - Bootstrap Loader (Clean & Fast)

# Exit if not interactive
case $- in
    *i*) ;;
      *) return;;
esac

# -------------------------------------------------------
# 0. Global Setup
# -------------------------------------------------------
export DOTFILES="$HOME/.dotfiles"
export DOTFILES_DEBUG="${DOTFILES_DEBUG:-0}"

log_debug() {
  [ "$DOTFILES_DEBUG" = "1" ] && echo "[DEBUG] $1"
}

# -------------------------------------------------------
# 1. Core Loader Functions (DRY)
# -------------------------------------------------------
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

# -------------------------------------------------------
# 2. History Optimization
# -------------------------------------------------------
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend checkwinsize

# Avoid duplicate PROMPT_COMMAND stacking
case "$PROMPT_COMMAND" in
  *history\ -a*) ;;
  *)
    PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
    ;;
esac

# -------------------------------------------------------
# 3. Prompt (Minimal & Fast)
# -------------------------------------------------------
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# -------------------------------------------------------
# 4. Git Symlink (self-healing)
# -------------------------------------------------------
GIT_TARGET="$DOTFILES/shared/git/.gitconfig"

if [ ! -L "$HOME/.gitconfig" ] || [ "$(readlink "$HOME/.gitconfig" 2>/dev/null)" != "$GIT_TARGET" ]; then
  rm -f "$HOME/.gitconfig"
  ln -s "$GIT_TARGET" "$HOME/.gitconfig"
  log_debug "Fixed git symlink"
fi

# -------------------------------------------------------
# 5. Load Modular Config
# -------------------------------------------------------
load_folder "$DOTFILES/wsl/bash/scripts"   "script"
load_folder "$DOTFILES/wsl/bash/functions" "function"

# -------------------------------------------------------
# 6. Optional: Bash Completion
# -------------------------------------------------------
if [ -f /usr/share/bash-completion/bash_completion ]; then
  source /usr/share/bash-completion/bash_completion
fi