#!/bin/bash

set -e

echo "=== UPDATE SYSTEM ==="
sudo apt update -y

echo "=== INSTALL DEPENDENCIES ==="
sudo apt install -y zsh git curl wget dconf-cli uuid-runtime gpg

# -----------------------------
# INSTALL EZA
# -----------------------------
if ! command -v eza &> /dev/null
then
  echo "=== INSTALL EZA ==="
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
    sudo gpg --dearmor -o /etc/apt/keyrings/eza.gpg

  echo "deb [signed-by=/etc/apt/keyrings/eza.gpg] \
https://deb.gierens.de stable main" | \
    sudo tee /etc/apt/sources.list.d/eza.list > /dev/null

  sudo apt update
  sudo apt install -y eza
fi

# -----------------------------
# SET DEFAULT SHELL
# -----------------------------
chsh -s $(which zsh)

# -----------------------------
# INSTALL OH MY ZSH
# -----------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# -----------------------------
# INSTALL POWERLEVEL10K
# -----------------------------
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# -----------------------------
# INSTALL PLUGINS
# -----------------------------
ZSH_CUSTOM_PLUGINS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

if [ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_PLUGINS/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting"
fi

# -----------------------------
# CONFIGURE .ZSHRC
# -----------------------------
ZSHRC="$HOME/.zshrc"

sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"

# Tambahkan alias eza
cat << 'EOF' >> "$ZSHRC"

# =========================
# EZA CONFIG
# =========================
alias ls='eza --icons --group-directories-first --color=always'
alias ll='eza -lah --icons --group-directories-first --git'
alias la='eza -a --icons --group-directories-first'
alias lt='eza --tree --icons'
alias l='eza -l --icons'

export EZA_COLORS="da=38;5;33:uu=38;5;33:gu=38;5;33"

EOF

# -----------------------------
# INSTALL NERD FONT
# -----------------------------
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
cd "$FONT_DIR"

wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

fc-cache -fv

# -----------------------------
# APPLY AYU DARK (MATE TERMINAL)
# -----------------------------
PROFILE_ID=$(dconf read /org/mate/terminal/global/default-profile | tr -d \')
BASE_PATH="/org/mate/terminal/profiles/${PROFILE_ID}"

dconf write ${BASE_PATH}/use-theme-colors false
dconf write ${BASE_PATH}/palette "['#0F1419', '#F07178', '#B8CC52', '#FFB454', '#59C2FF', '#D2A6FF', '#95E6CB', '#E6E1CF', '#5C6773', '#F07178', '#B8CC52', '#FFB454', '#59C2FF', '#D2A6FF', '#95E6CB', '#FFFFFF']"
dconf write ${BASE_PATH}/background-color "'#0F1419'"
dconf write ${BASE_PATH}/foreground-color "'#E6E1CF'"

echo ""
echo "===================================="
echo " INSTALLATION COMPLETE"
echo "===================================="
echo ""
echo "1. Logout & login ulang"
echo "2. Set font terminal ke: MesloLGS NF"
echo "3. Jalankan: p10k configure (jika tidak otomatis)"
echo ""
