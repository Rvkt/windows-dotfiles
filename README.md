# Rvkt's Dotfiles


```bash
git clone https://github.com/Rvkt/windows-dotfiles.git .dotfiles
```
---

## 🐧 WSL Setup (Ubuntu 24.04)

This guide sets up the dotfiles in a native WSL environment with proper symlinks and modular configuration.


### 1. Setup Bash Configuration

Replace the default `.bashrc` with the managed version:

```bash
rm -f ~/.bashrc
ln -s ~/.dotfiles/wsl/bash/.bashrc ~/.bashrc
```

Reload:

```bash
source ~/.bashrc
```

---

### 2. Setup Git Configuration

Link the shared Git config:

```bash
rm -f ~/.gitconfig
ln -s ~/.dotfiles/shared/git/.gitconfig ~/.gitconfig
```

---

### 3. Verify Setup

```bash
echo $DOTFILES
git config --list
```

Expected:

- `DOTFILES` → `~/.dotfiles`
    
- Git config loads without errors
    
---