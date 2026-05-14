#!/usr/bin/env bash
# Installs essential terminal setup on Ubuntu/Debian.
# Idempotent — safe to re-run.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf "\n\033[1;34m==> %s\033[0m\n" "$*"; }

# --- 1. apt packages ---
log "Installing apt packages"
sudo apt-get update -qq
sudo apt-get install -y \
  zsh \
  git \
  curl \
  ripgrep \
  fd-find \
  bat \
  fzf \
  unzip \
  build-essential

# --- 2. GitHub CLI ---
if ! command -v gh >/dev/null 2>&1; then
  log "Installing GitHub CLI"
  (type -p wget >/dev/null || sudo apt-get install -y wget)
  sudo mkdir -p -m 755 /etc/apt/keyrings
  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y gh
fi

# --- 3. lsd ---
if ! command -v lsd >/dev/null 2>&1; then
  log "Installing lsd"
  ARCH=$(dpkg --print-architecture)
  LSD_URL=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest \
    | grep "browser_download_url.*${ARCH}.deb" | grep -v musl | head -1 \
    | cut -d '"' -f 4)
  curl -fsSL -o /tmp/lsd.deb "$LSD_URL"
  sudo dpkg -i /tmp/lsd.deb
  rm /tmp/lsd.deb
fi

# --- 4. zoxide ---
if ! command -v zoxide >/dev/null 2>&1; then
  log "Installing zoxide"
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# --- 5. Starship ---
if ! command -v starship >/dev/null 2>&1; then
  log "Installing Starship"
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# --- 6. Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing Oh My Zsh"
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# --- 7. Zsh plugins ---
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  log "Installing zsh-autosuggestions"
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  log "Installing zsh-syntax-highlighting"
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# --- 8. Symlink dotfiles ---
log "Linking dotfiles"
backup_and_link() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "${dst}.backup.$(date +%s)"
  fi
  ln -sfn "$src" "$dst"
}

backup_and_link "$DOTFILES_DIR/.zshrc"        "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/.gitconfig"    "$HOME/.gitconfig"

mkdir -p "$HOME/.config"
backup_and_link "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"

# --- 9. Default shell ---
ZSH_PATH="$(command -v zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
  log "Setting zsh as default shell (may prompt for password)"
  sudo chsh -s "$ZSH_PATH" "$USER"
fi

log "Done. Log out and back in, or run: exec zsh"
