#!/usr/bin/env bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

export DEBIAN_FRONTEND=noninteractive

is_debian_like() {
  grep -qi "debian" /etc/os-release
}

apt_install() {
  sudo -E apt-get update -y
  sudo -E apt-get install -y "$@"
}

ensure_symlink() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "Symlink exists: $dest (skipping)"
  else
    ln -s "$src" "$dest"
    echo "Created symlink: $dest -> $src"
  fi
}

ensure_terminfo() {
  # ensure_terminfo TERMNAME
  local term="$1"
  if infocmp "$term" >/dev/null 2>&1; then
    echo "terminfo for $term already present."
    return 0
  fi

  echo "Installing terminfo for $term..."
  case "$term" in
    xterm-kitty)
      # Try official package first (Ubuntu/Debian)
      sudo -E apt-get install -y kitty-terminfo >/dev/null 2>&1 || true
      if ! infocmp "$term" >/dev/null 2>&1; then
        # Fallback: compile from upstream source
        curl -fsSL https://raw.githubusercontent.com/kovidgoyal/kitty/master/terminfo/x/xterm-kitty | tic -x -
      fi
      ;;
    tmux-256color)
      # Usually in ncurses-term
      sudo -E apt-get install -y ncurses-term >/dev/null 2>&1 || true
      if ! infocmp "$term" >/dev/null 2>&1; then
        # Last resort: pull latest terminfo source and build
        curl -fsSL https://invisible-island.net/datafiles/current/terminfo.src.gz \
        | gunzip | tic -x -  >/dev/null 2>&1 || true
      fi
      ;;
    *)
      # Generic attempt: try ncurses-term then invisible-island fallback
      sudo -E apt-get install -y ncurses-term >/dev/null 2>&1 || true
      if ! infocmp "$term" >/dev/null 2>&1; then
        curl -fsSL https://invisible-island.net/datafiles/current/terminfo.src.gz \
        | gunzip | tic -x -  >/dev/null 2>&1 || true
      fi
      ;;
  esac

  if infocmp "$term" >/dev/null 2>&1; then
    echo "terminfo for $term installed."
  else
    echo "WARNING: terminfo for $term still missing; will add a runtime fallback."
  fi
}

# --- 1) Base packages & Node.js ---
if is_debian_like; then
  echo "Debian-based system detected. Installing dependencies..."
  apt_install software-properties-common ca-certificates curl git wget gnupg lsb-release fontconfig build-essential pkg-config unzip
  ensure_terminfo xterm-kitty
  ensure_terminfo tmux-256color
  sudo -E add-apt-repository -y ppa:neovim-ppa/unstable || true
  apt_install zsh neovim tmux ripgrep

  # NodeSource (Node.js 20 LTS)
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  apt_install nodejs
else
  echo "Unsupported system. Exiting..."
  exit 1
fi

echo "Node/npm versions:"
node -v || true
npm -v || true

# --- 2) Tmux symlink (idempotent) ---
echo "Linking tmux config..."
ensure_symlink "$HOME/.config/tmux/tmux.conf" "$HOME/.tmux.conf"

# --- 3) Oh My Zsh (idempotent, non-interactive) ---
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh already installed. Skipping."
else
  echo "Installing Oh My Zsh (non-interactive)..."
  export RUNZSH=no
  export CHSH=no
  export KEEP_ZSHRC=yes
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# --- 4) Zsh plugins (idempotent) ---
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
PLUG_DIR="$ZSH_CUSTOM_DIR/plugins"
mkdir -p "$PLUG_DIR"

if [ -d "$PLUG_DIR/zsh-syntax-highlighting" ]; then
  echo "zsh-syntax-highlighting present."
else
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$PLUG_DIR/zsh-syntax-highlighting"
fi

if [ -d "$PLUG_DIR/zsh-autosuggestions" ]; then
  echo "zsh-autosuggestions present."
else
  git clone https://github.com/zsh-users/zsh-autosuggestions.git \
    "$PLUG_DIR/zsh-autosuggestions"
fi

# --- 5) Update ~/.zshrc with SSH-aware plugin logic (no theme enforced) ---
if [ ! -f "$HOME/.zshrc" ]; then
  echo "Creating empty ~/.zshrc"
  touch "$HOME/.zshrc"
fi

SSH_BLOCK_MARK="# >>> SSH_AWARE_PLUGINS (managed) >>>"
if ! grep -qF "$SSH_BLOCK_MARK" "$HOME/.zshrc"; then
  echo "Injecting SSH-aware plugin block into ~/.zshrc"

  # Comment out any existing 'plugins=(...)' lines to prevent overrides.
  # (We keep them as comments so you can reference/restore later.)
  sed -i 's/^[[:space:]]*plugins=(/# (disabled by installer) &/' "$HOME/.zshrc"

  # Prepend our managed block before the first oh-my-zsh sourcing if present; else just append at end.
  if grep -qE 'oh-my-zsh\.sh' "$HOME/.zshrc"; then
    # Insert block BEFORE first 'oh-my-zsh.sh' source line
    awk -v block="$(cat <<'EOF'
# >>> SSH_AWARE_PLUGINS (managed) >>>
# Ensure UTF-8 locale (prevents glyph width issues)
export LANG=${LANG:-en_GB.UTF-8}
export LC_ALL=${LC_ALL:-en_GB.UTF-8}

# Choose a leaner plugin set over SSH to reduce redraw/latency issues.
if [[ -n $SSH_CONNECTION || -n $SSH_TTY ]]; then
  plugins=(git)
else
  plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
  # Autosuggestions tuning
  ZSH_AUTOSUGGEST_USE_ASYNC=1
  ZSH_AUTOSUGGEST_STRATEGY=(history)
  ZSH_AUTOSUGGEST_MANUAL_REBIND=1
fi
# <<< SSH_AWARE_PLUGINS (managed) <<<
EOF
)" '
      BEGIN { printed=0 }
      {
        if (!printed && $0 ~ /oh-my-zsh\.sh/) {
          print block
          printed=1
        }
        print
      }
    ' "$HOME/.zshrc" > "$HOME/.zshrc.tmp" && mv "$HOME/.zshrc.tmp" "$HOME/.zshrc"
  else
    cat >>"$HOME/.zshrc" <<'EOF'

# >>> SSH_AWARE_PLUGINS (managed) >>>
export LANG=${LANG:-en_GB.UTF-8}
export LC_ALL=${LC_ALL:-en_GB.UTF-8}

if [[ -n $SSH_CONNECTION || -n $SSH_TTY ]]; then
  plugins=(git)
else
  plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
  ZSH_AUTOSUGGEST_USE_ASYNC=1
  ZSH_AUTOSUGGEST_STRATEGY=(history)
  ZSH_AUTOSUGGEST_MANUAL_REBIND=1
fi
# <<< SSH_AWARE_PLUGINS (managed) <<<
EOF
  fi
else
  echo "SSH-aware plugin block already present. Skipping."
fi

# Ensure OMZ bootstrap is present (do not enforce theme; let each system decide)
if ! grep -qE 'oh-my-zsh\.sh' "$HOME/.zshrc"; then
  cat >>"$HOME/.zshrc" <<'EOF'

# Oh My Zsh bootstrap (theme is intentionally NOT enforced here)
export ZSH="$HOME/.oh-my-zsh"
[ -s "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# Faster, safer completion cache
autoload -Uz compinit; compinit -C
EOF
fi

echo "Done. Optional: make zsh your login shell with:"
echo "  chsh -s \"$(command -v zsh)\""
echo "Restart your terminal. Configure your preferred theme (e.g., powerlevel10k) per system."
