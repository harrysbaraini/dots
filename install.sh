#!/usr/bin/env bash
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

# Install Karabiner DriverKit
if ! [ -d "/Applications/.Karabiner-VirtualHIDDevice-Manager.app" ]; then
  echo "Installing Karabiner DriverKit..."
  curl -L -o /tmp/karabiner-driver.pkg \
    https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/latest/download/Karabiner-DriverKit-VirtualHIDDevice.pkg

  sudo installer -pkg /tmp/karabiner-driver.pkg -target /

  echo "Activate the driver extension"
  /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager activate

  echo "⚠️  Go to System Settings → Privacy & Security and click Allow, then press enter. You may need to add /opt/homebrew/bin/kanata to Input Monitoring as well."
  read -r
fi

# Install brew packages
brew bundle

# Install SbarLua for sketchybar
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

# Initialize dotfiles
chezmoi init https://github.com/harrysbaraini/dots.git
chezmoi apply

# Restart services
brew services restart sketchybar
