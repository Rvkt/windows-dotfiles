# =======================================================
# SSH Agent — Auto-load wsl_ssh key
# =======================================================
if command -v ssh-agent &>/dev/null; then
    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)" > /dev/null 2>&1
        ssh-add ~/.ssh/wsl_ssh > /dev/null 2>&1
    fi
fi

# =======================================================
# Navigation
# =======================================================
alias ..='cd ..'
alias ...='cd ../..'
alias home='cd ~'
alias ~='cd ~'

# =======================================================
# File Listing
# =======================================================
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# =======================================================
# System
# =======================================================
alias c='clear'
alias cls='clear'
alias reload='source ~/.zshrc'
alias dotfiles='cd ~/.dotfiles'

# =======================================================
# Git
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
# Package Management
# =======================================================
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias purge='sudo apt purge'

# =======================================================
# Search / Disk / Network
# =======================================================
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias myip='curl ifconfig.me'