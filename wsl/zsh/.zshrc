# =======================================================
# ZSH Bootstrap
# =======================================================

export DOTFILES="$HOME/.dotfiles"

# =======================================================
# OH MY ZSH
# =======================================================

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

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
HISTFILE="$HOME/.zsh_history"

setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# =======================================================
# COMPLETIONS
# =======================================================

autoload -Uz compinit

if [[ ! -f ~/.zcompdump || ~/.zcompdump -nt ~/.zshrc ]]; then
  compinit
else
  compinit -C
fi

# =======================================================
# MODULAR LOADER
# =======================================================

load_folder() {
  local path="$1"

  [[ -d "$path" ]] || return

  setopt local_options nullglob

  for file in "$path"/*.sh "$path"/*.zsh; do
    [[ -r "$file" ]] && source "$file"
  done
}

load_folder "$DOTFILES/wsl/zsh/scripts"
load_folder "$DOTFILES/wsl/zsh/functions"