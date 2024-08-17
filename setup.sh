#!/bin/bash

# This assumes we're on a fresh new install of a Debian/Ubuntu distro

# Don't run if root
if [ "$(id -u)" = "0" ]; then
   echo "This script must not be run as root" 1>&2
   exit 1
fi

# Needed pretty much everytime

# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# git
sudo apt install git-all
# - lazygit
brew install jesseduffield/lazygit/lazygit
# fzf
brew install fzf
# chezmoi
brew install chezmoi
# oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# keychain
sudo apt install keychain
