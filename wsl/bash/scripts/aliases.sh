# -------------------------------------------------------
# Aliases - Core Productivity
# -------------------------------------------------------

# ---------- File Listing ----------
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# ---------- Navigation ----------
alias ..='cd ..'
alias ...='cd ../..'
alias home='cd ~'
alias ~='cd ~'

# ---------- System ----------
alias cls='clear'
alias c='clear'

# ---------- Git ----------
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# ---------- System Package ----------
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias purge='sudo apt purge'

# ---------- Search ----------
alias grep='grep --color=auto'

# ---------- Disk ----------
alias df='df -h'
alias du='du -h'

# ---------- Networking ----------
alias myip='curl ifconfig.me'

# ---------- Misc ----------
alias reload='source ~/.bashrc'
alias dotfiles='cd ~/.dotfiles'