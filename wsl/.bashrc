# ~/.bashrc - Clean Developer Setup

# Exit if not interactive
case $- in
    *i*) ;;
      *) return;;
esac

# -----------------------------
# 🧠 History Optimization
# -----------------------------
HISTCONTROL=ignoreboth
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend
shopt -s checkwinsize

# -----------------------------
# 🎨 Prompt (Clean + Colored)
# -----------------------------
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# -----------------------------
# 📁 Aliases (Core Productivity)
# -----------------------------
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'

# -----------------------------
# 🔧 Git Shortcuts
# -----------------------------
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'

# -----------------------------
# 📂 Navigation Shortcuts
# -----------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias home='cd ~'

# -----------------------------
# 📦 System Utilities
# -----------------------------
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install'

# -----------------------------
# 🔁 Auto-load aliases file (optional)
# -----------------------------
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# -----------------------------
# ⚙️ Bash Completion
# -----------------------------
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi