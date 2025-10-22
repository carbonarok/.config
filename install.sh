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
  local term="$1"
  if infocmp "$term" >/dev/null 2>&1; then
    echo "terminfo for $term already present."
    return 0
  fi

  echo "Installing terminfo for $term..."
  case "$term" in
    xterm-kitty)
      sudo -E apt-get install -y kitty-terminfo >/dev/null 2>&1 || true
      if ! infocmp "$term" >/dev/null 2>&1; then
        curl -fsSL https://raw.githubusercontent.com/kovidgoyal/kitty/master/terminfo/x/xterm-kitty | tic -x -
      fi
      ;;
    tmux-256color)
      sudo -E apt-get install -y ncurses-term >/dev/null 2>&1 || true
      if ! infocmp "$term" >/dev/null 2>&1; then
        curl -fsSL https://invisible-island.net/datafiles/current/terminfo.src.gz \
        | gunzip | tic -x - >/dev/null 2>&1 || true
      fi
      ;;
    *)
      sudo -E apt-get install -y ncurses-term >/dev/null 2>&1 || true
      if ! infocmp "$term" >/dev/null 2>&1; then
        curl -fsSL https://invisible-island.net/datafiles/current/terminfo.src.gz \
        | gunzip | tic -x - >/dev/null 2>&1 || true
      fi
      ;;
  esac

  if infocmp "$term" >/dev/null 2>&1; then
    echo "terminfo for $term installed."
  else
    echo "WARNING: terminfo for $term still missing; will add a runtime fallback."
  fi
}

# --- Base setup ---
if is_debian_like; then
  echo "Debian-based system detected. Installing dependencies..."
  apt_install software-properties-common ca-certificates curl git wget gnupg lsb-release fontconfig build-essential pkg-config unzip fd-find pipx
  ensure_terminfo xterm-kitty
  ensure_terminfo tmux-256color
  sudo -E add-apt-repository -y ppa:neovim-ppa/unstable || true
  apt_install zsh neovim tmux ripgrep

  # Node.js 20
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  apt_install nodejs
else
  echo "Unsupported system. Exiting..."
  exit 1
fi

echo "Node/npm versions:"
node -v || true
npm -v || true

echo "Linking tmux config..."
ensure_symlink "$HOME/.config/tmux/tmux.conf" "$HOME/.tmux.conf"

echo "Installing tmuxp..."
pipx install tmuxp

# --- Oh My Zsh ---
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh already installed. Skipping."
else
  echo "Installing Oh My Zsh (non-interactive)..."
  export RUNZSH=no
  export CHSH=no
  export KEEP_ZSHRC=yes
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# --- Plugins ---
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
PLUG_DIR="$ZSH_CUSTOM_DIR/plugins"
THEMES_DIR="$ZSH_CUSTOM_DIR/themes"
mkdir -p "$PLUG_DIR" "$THEMES_DIR"

# Install Powerlevel10k if missing
if [ -d "$THEMES_DIR/powerlevel10k" ]; then
  echo "Powerlevel10k already installed."
else
  echo "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$THEMES_DIR/powerlevel10k"
fi

# zsh plugins
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

# --- Ensure ~/.zshrc exists ---
if [ ! -f "$HOME/.zshrc" ]; then
  echo "Creating empty ~/.zshrc"
  touch "$HOME/.zshrc"
fi

# --- SSH-aware plugins block ---
SSH_BLOCK_MARK="# >>> SSH_AWARE_PLUGINS (managed) >>>"
if ! grep -qF "$SSH_BLOCK_MARK" "$HOME/.zshrc"; then
  echo "Injecting SSH-aware plugin block into ~/.zshrc"

  sed -i 's/^[[:space:]]*plugins=(/# (disabled by installer) &/' "$HOME/.zshrc"

  if grep -qE 'oh-my-zsh\.sh' "$HOME/.zshrc"; then
    awk -v block="$(cat <<'EOF'
# >>> SSH_AWARE_PLUGINS (managed) >>>
export LANG=${LANG:-en_GB.UTF-8}
export LC_ALL=${LC_ALL:-en_GB.UTF-8}

# Choose a leaner plugin set over SSH to reduce redraw/latency issues.
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

# --- OMZ bootstrap ---
if ! grep -qE 'oh-my-zsh\.sh' "$HOME/.zshrc"; then
  cat >>"$HOME/.zshrc" <<'EOF'

# Oh My Zsh bootstrap
export ZSH="$HOME/.oh-my-zsh"
[ -s "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"
autoload -Uz compinit; compinit -C
EOF
fi

# --- Set theme to Powerlevel10k ---
if grep -qE '^[[:space:]]*ZSH_THEME=' "$HOME/.zshrc"; then
  sed -i 's|^[[:space:]]*ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
else
  echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
fi

# --- Source ~/.p10k.zsh if present ---
if ! grep -q '^\s*\[\[ -r ~/.p10k.zsh \]\]' "$HOME/.zshrc"; then
  cat >>"$HOME/.zshrc" <<'EOF'

# Powerlevel10k user config (only if present)
[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh
EOF
fi

# --- Make zsh default shell ---
chsh -s "$(command -v zsh)"
sudo cp sync-system.sh /usr/local/bin/sync-system

echo "Done"
