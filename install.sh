!/usr/bin/env bash
set -e

# Install xCode cli tools
echo "Installing commandline tools..."
xcode-select --install

# Homebrew
## Install
echo "Installing Brew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

# Install proton-pass-cli
curl -fsSL https://proton.me/download/pass-cli/install.sh | bash

# Install brew packages
brew bundle

# Install SbarLua for sketchybar
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

# Initialize dotfiles
chezmoi init https://github.com/harrysbaraini/dots.git
chezmoi apply

# Restart services
brew services restart sketchybar
