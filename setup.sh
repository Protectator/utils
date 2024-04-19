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
# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install --lts
nvm use --lts
# - tldr
nvm i -g tldr

# micro
curl https://getmic.ro | bash
# chezmoi
brew install chezmoi
# keychain
sudo apt install keychain

# Useful to dev
brew install hyperfine

# jq
sudo apt-get install jq
