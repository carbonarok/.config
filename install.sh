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

upsert_zshrc_var() {
  # upsert_zshrc_var VAR_NAME "value with spaces allowed"
  local name="$1"; shift
  local value="$*"
  local file="$HOME/.zshrc"
  if grep -qE "^[[:space:]]*${name}=" "$file"; then
    # replace existing assignment
    sed -i "s|^[[:space:]]*${name}=.*|${name}=\"${value}\"|g" "$file"
  else
    echo "${name}=\"${value}\"" >> "$file"
  fi
}

# --- 1) Base packages & Node.js ---
if is_debian_like; then
  echo "Debian-based system detected. Installing dependencies..."
  apt_install software-properties-common ca-certificates curl git wget gnupg lsb-release
  sudo -E add-apt-repository -y ppa:neovim-ppa/stable || true
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

# --- 4) Powerlevel10k theme (idempotent) ---
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
THEMES_DIR="$ZSH_CUSTOM_DIR/themes"
PL10K_DIR="$THEMES_DIR/powerlevel10k"

if [ -d "$PL10K_DIR" ]; then
  echo "Powerlevel10k already present. Skipping clone."
else
  echo "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$PL10K_DIR"
fi

# --- 5) Fonts (MesloLGS NF) ---
echo "Installing MesloLGS Nerd Font..."
mkdir -p "$HOME/.local/share/fonts"
pushd "$HOME/.local/share/fonts" >/dev/null
for f in \
  "MesloLGS NF Regular.ttf" \
  "MesloLGS NF Bold.ttf" \
  "MesloLGS NF Italic.ttf" \
  "MesloLGS NF Bold Italic.ttf"
do
  if [ -f "$f" ]; then
    echo "Font $f exists. Skipping."
  else
    wget -q "https://github.com/romkatv/powerlevel10k-media/raw/master/${f// /%20}"
  fi
done
fc-cache -fv >/dev/null
popd >/dev/null

# --- 6) Optional p10k config copy ---
if [ -f "./other/.p10k.zsh" ]; then
  echo "Copying p10k configuration..."
  cp ./other/.p10k.zsh "$HOME/.p10k.zsh"
else
  echo "No ./other/.p10k.zsh found. You can create one later or run 'p10k configure'."
fi

# --- 7) Zsh plugins (idempotent) ---
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

# --- 8) Update ~/.zshrc: theme, plugins, p10k sourcing (idempotent) ---
if [ ! -f "$HOME/.zshrc" ]; then
  echo "Creating empty ~/.zshrc"
  touch "$HOME/.zshrc"
fi

# Set theme
upsert_zshrc_var ZSH_THEME "powerlevel10k/powerlevel10k"

# Ensure plugins list contains our plugins (merge-friendly)
if grep -qE '^[[:space:]]*plugins=\(' "$HOME/.zshrc"; then
  # Normalize to a single line for simple edits
  sed -i ':a;N;$!ba;s/plugins=\([^\n]*\)\n\([^)]*\)/plugins=\1 \2/g' "$HOME/.zshrc"
  sed -i 's/plugins=(/plugins=(git /' "$HOME/.zshrc"
  for p in zsh-autosuggestions zsh-syntax-highlighting; do
    grep -q "$p" "$HOME/.zshrc" || sed -i "s/plugins=(/plugins=(${p} /" "$HOME/.zshrc"
  done
else
  echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$HOME/.zshrc"
fi

# Source p10k config if present
if ! grep -q '^\s*\[\[ -r ~/.p10k.zsh \]\]' "$HOME/.zshrc"; then
  cat >>"$HOME/.zshrc" <<'EOF'

# Powerlevel10k instant prompt and config
# Enable instant prompt to speed up shell startup.
if [[ -r ~/.zshrc.zni ]]; then source ~/.zshrc.zni; fi
[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh
EOF
fi

echo "Done. Optional: make zsh your login shell with:"
echo "  chsh -s \"$(command -v zsh)\""
echo "Restart your terminal and set your terminal font to 'MesloLGS NF'."

