# ~/.zshrc - Bootstrap Loader (Clean & Fast)
# Author : Rvkt
# Focus  : Git-aware prompt via Oh My Zsh, modular config

export DOTFILES="$HOME/.dotfiles"
export DOTFILES_DEBUG="${DOTFILES_DEBUG:-0}"
export EDITOR="vim"
export VISUAL="vim"

# =======================================================
# OH MY ZSH
# =======================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"          # clean default; change anytime

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# =======================================================
# HISTORY
# =======================================================
HISTSIZE=10000
SAVEHIST=20000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# =======================================================
# MODULAR CONFIG
# =======================================================
load_folder() {
  local path="$1"
  [ -d "$path" ] || return

  # nullglob prevents error when no files match
  setopt local_options nullglob
  for file in "$path"/*.sh "$path"/*.zsh; do
    [ -r "$file" ] && source "$file"
  done
}

load_folder "$DOTFILES/wsl/zsh/scripts"
load_folder "$DOTFILES/wsl/zsh/functions"

# =======================================================
# BASH COMPLETION (zsh can use bash completions)
# =======================================================
autoload -Uz compinit && compinit