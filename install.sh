#!/bin/bash

echo "💻 Setting up your Mac..."

# Check for Oh My Zsh and install if we don't have it
#if test ! $(which omz); then
if [ -d "$ZSH" ]; then
  printf "Oh My Zsh is already installed. Skipping...\n"
else
  printf "📦 Installing Oh My Zsh...\n"
  curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash

  # Clone plugins
  if ! [ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "📦 Installing Zsh Powerlevel10k Theme...\n"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  else
    echo "Powerlevel10k Theme already installed, skiping...\n"
  fi

  if ! [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "📦 Installing Zsh zsh-syntax-highlighting Plugin...\n"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  else
    echo "zsh-syntax-highlighting Plugin already installed, skiping...\n"
  fi

  if ! [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "📦 Installing Zsh zsh-autosuggestions Plugin...\n"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  else
    echo "zsh-autosuggestions Plugin already installed, skiping...\n"
  fi

  # Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
  rm $HOME/.zshrc
  ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc
  ln -s $HOME/.dotfiles/.zprofile $HOME/.zprofile
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  printf "📦 Installing Homebrew...\n"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  source ~/.zprofile
else
  printf "Homebrew is already installed. Skipping....\n"
fi

# Update Homebrew recipes
echo "Updating Brew..."
brew update

echo "Upgrading Brew..."
brew upgrade

echo "Off analytics..."
brew analytics off
export HOMEBREW_NO_ANALYTICS=1

# Removes .p10k.zsh from $HOME (if it exists) and symlinks the .p10k.zsh file from the .dotfiles
rm $HOME/.p10k.zsh
ln -s $HOME/.dotfiles/.p10k.zsh $HOME/.p10k.zsh

# Install all our dependencies with bundle (See Brewfile)
#brew tap homebrew/bundle
#brew bundle --file $HOME/.dotfiles/Brewfile

# Install all our dependencies
echo "📦 Installing Brew packages..."
xargs -n1 -t brew install < $HOME/.dotfiles/install/brew-list.txt
echo "📦 Installing Brew Cask packages..."
xargs -n1 -t brew install --cask < $HOME/.dotfiles/install/brew-list-cask.txt

# Clone Github repositories
#$HOME/.dotfiles/clone.sh

# symlinks
ln -s $HOME/.dotfiles/.vimrc $HOME/.vimrc
ln -s $HOME/.dotfiles/.gitconfig $HOME/.gitconfig
ln -s $HOME/.dotfiles/.gitignore $HOME/.gitignore
ln -s $HOME/.dotfiles/.tool-versions $HOME/.tool-versions
ln -s $HOME/.dotfiles/.fzf.zsh $HOME/.fzf.zsh
ln -s $HOME/.dotfiles/.ssh/config $HOME/.ssh/config

echo "🧹 Homebrew Cleanup..."
brew cleanup

echo "Open iTerm2 and type p10k configure to install fonts"
