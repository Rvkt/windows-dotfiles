# SSH Agent — Auto-load wsl_ssh key
# ~/.dotfiles/wsl/zsh/scripts/ssh.zsh

if command -v ssh-agent &>/dev/null; then
    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)" > /dev/null 2>&1
        ssh-add ~/.ssh/wsl_ssh > /dev/null 2>&1
    fi
fi