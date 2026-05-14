# ============================================================
# .zshrc — portable (Mac + Linux VPS)
# ============================================================

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
ZSH_DISABLE_COMPFIX="true"
zstyle ':omz:update' mode auto

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source $ZSH/oh-my-zsh.sh

# --- History ---
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

# --- Editor ---
export EDITOR='nvim'
export VISUAL='nvim'

# --- PATH (must come before tool init below) ---
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# --- Starship prompt ---
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# --- Zoxide (smart cd) ---
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# --- Aliases ---
alias vim=nvim
alias c='clear'

# lsd (modern ls) — fallback to ls if not installed
if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd'
  alias l='lsd -l'
  alias la='lsd -a'
  alias lla='lsd -la'
  alias lt='lsd --tree'
fi

# bat (Ubuntu installs as `batcat`)
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
fi

# fd (Ubuntu installs as `fdfind`)
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

# --- Local overrides (machine-specific, not versioned) ---
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
