#!/bin/bash

set -e

DOTFILES_DIR="$HOME/.dotfiles"

echo "💻 Setting up your Mac..."

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.ssh"

# Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh is already installed. Skipping..."
else
  echo "📦 Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Powerlevel10k
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "📦 Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
  echo "Powerlevel10k already installed. Skipping..."
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "📦 Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo "zsh-syntax-highlighting already installed. Skipping..."
fi

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "📦 Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "zsh-autosuggestions already installed. Skipping..."
fi

# Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "📦 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew is already installed. Skipping..."
fi

echo "Updating Homebrew..."
brew update

echo "Upgrading Homebrew..."
brew upgrade

echo "Disabling Homebrew analytics..."
brew analytics off || true
export HOMEBREW_NO_ANALYTICS=1

echo "📦 Installing Brew packages..."
if [ -f "$DOTFILES_DIR/macos/install/brew-list.txt" ]; then
  xargs -n1 -t brew install < "$DOTFILES_DIR/macos/install/brew-list.txt"
fi

echo "📦 Installing Brew Cask packages..."
if [ -f "$DOTFILES_DIR/macos/install/brew-list-cask.txt" ]; then
  xargs -n1 -t brew install --cask < "$DOTFILES_DIR/macos/install/brew-list-cask.txt"
fi

echo "🔗 Creating symlinks..."

ln -sfn "$DOTFILES_DIR/macos/zsh/.zshrc" "$HOME/.zshrc"
ln -sfn "$DOTFILES_DIR/macos/zsh/.zprofile" "$HOME/.zprofile"
ln -sfn "$DOTFILES_DIR/macos/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sfn "$DOTFILES_DIR/macos/zsh/.fzf.zsh" "$HOME/.fzf.zsh"

ln -sfn "$DOTFILES_DIR/common/git/.gitconfig" "$HOME/.gitconfig"
ln -sfn "$DOTFILES_DIR/common/git/.gitignore" "$HOME/.gitignore"
ln -sfn "$DOTFILES_DIR/common/vim/.vimrc" "$HOME/.vimrc"
ln -sfn "$DOTFILES_DIR/common/tool-versions/.tool-versions" "$HOME/.tool-versions"

if [ -d "$DOTFILES_DIR/.config/nvim" ]; then
  mkdir -p "$HOME/.config"
  ln -sfn "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
fi

echo "🧹 Homebrew Cleanup..."
brew cleanup

echo ""
echo "✅ macOS setup completed."
echo "Open iTerm2 and run: p10k configure"
