export SSH_KEY="$HOME/.ssh/wsl_ssh"

if command -v keychain >/dev/null 2>&1; then
  eval "$(keychain --eval --quiet "$SSH_KEY")"
fi