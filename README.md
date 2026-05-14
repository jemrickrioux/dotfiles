# dotfiles

Portable shell setup for Mac and Linux VPS.

## Install

```bash
git clone https://github.com/jemrickrioux/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
exec zsh
```

## Contents

- `.zshrc` — zsh + oh-my-zsh + plugins, portable Mac/Linux
- `.gitconfig` — git identity and defaults
- `starship.toml` — prompt config
- `install.sh` — Ubuntu/Debian installer
- `hooks/pre-commit` — gitleaks secret scan

## Machine-specific overrides

Put machine-specific config in `~/.zshrc.local` (gitignored, sourced by `.zshrc`).

## Pre-commit hook

After cloning, enable the gitleaks hook:

```bash
git config core.hooksPath hooks
```
