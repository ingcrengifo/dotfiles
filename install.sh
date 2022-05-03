#!/bin/sh

echo "💻 Setting up your Mac..."

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  printf "📦 Installing Oh My Zsh...\n"
  /bin/sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Clone plugins
echo "Cloning zsh Plugins..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  printf "📦 Installing Homebrew...\n"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
#  echo 'export PATH="/opt/homebrew/bin:$PATH"' >> $HOME/.zshrc
fi

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm $HOME/.zshrc
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc
ln -s $HOME/.dotfiles/.zprofile $HOME/.zprofile

# Removes .p10k.zsh from $HOME (if it exists) and symlinks the .p10k.zsh file from the .dotfiles
rm $HOME/.p10k.zsh
ln -s $HOME/.dotfiles/.p10k.zsh $HOME/.p10k.zsh

# Update Homebrew recipes
echo "Updating Brew..."
brew update

# Install all our dependencies with bundle (See Brewfile)
#brew tap homebrew/bundle
#brew bundle --file $HOME/.dotfiles/Brewfile

# Install all our dependencies
echo "Installing Brew packages..."
xargs -n1 -t brew install < $HOME/.dotfiles/install/brew-list.txt
echo "Installing Brew Cask packages..."
xargs -n1 -t brew install --cask < $HOME/.dotfiles/install/brew-list-cask.txt

# Clone Github repositories
#$HOME/.dotfiles/clone.sh

# symlinks
ln -s $HOME/.dotfiles/.vimrc $HOME/.vimrc
ln -s $HOME/.dotfiles/.gitconfig $HOME/.gitconfig
ln -s $HOME/.dotfiles/.gitignore $HOME/.gitignore
ln -s $HOME/.dotfiles/.tool-versions $HOME/.tool-versions

