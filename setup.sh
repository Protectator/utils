#!/bin/bash
# To run this script, run :
# /bin/bash -c "$(curl -fsSL https://kewin.dev/setup)"

set -e

# This assumes we're on a fresh new install of a Debian/Ubuntu distro

# Don't run if root
if [ "$(id -u)" = "0" ]; then
   echo "This script must not be run as root" 1>&2
   exit 1
fi

install_most_common()
{
  sudo apt -y install wget curl make htop unzip vim ssh-import-id tmux
}

echo "OK to install the following ?"
echo ""
echo "◆ wget"
echo "◆ curl"
echo "◆ make"
echo "◆ htop"
echo "◆ unzip"
echo "◆ vim"
echo "◆ ssh-import-id"
echo "◆ tmux"
echo ""

sudo apt update

select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_most_common; break;;
        No ) break;;
    esac
done

GITHUB_USERNAME=Protectator
EMAIL=me@kewindousse.ch

# Getting some info from the user
echo "GitHub username ? (default: $GITHUB_USERNAME)"
read -r input
GITHUB_USERNAME=${input:-$GITHUB_USERNAME}

echo "e-mail address to use for SSH key and git ? (default: $EMAIL)"
read -r input
EMAIL=${input:-$EMAIL}

echo "OK to import GitHub keys of $GITHUB_USERNAME ?"

import_gh_keys()
{
  if command -v ssh-import-id-gh &>/dev/null; then
    ssh-import-id-gh "$GITHUB_USERNAME"
  else
    mkdir -p ~/.ssh
    curl -fsSL "https://github.com/$GITHUB_USERNAME.keys" >> ~/.ssh/authorized_keys
  fi
}

select yn in "Yes" "No"; do
    case $yn in
        Yes ) import_gh_keys; break;;
        No ) break;;
    esac
done

echo "OK to install the following ?"
echo ""
echo "◆ openssh-client"
echo ""

install_openssh()
{
  # openssh-client
  sudo apt install -y openssh-client
}

select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_openssh; break;;
        No ) break;;
    esac
done

echo "Generate SSH key ?"
echo ""

generate_key()
{
   ssh-keygen -t ed25519 -C "$EMAIL"
   
   echo "Add the public key to your GitHub account : "
   echo ""
   echo "https://github.com/settings/ssh/new"
   
   cat ~/.ssh/id_ed25519.pub
   
   echo "Press any key to continue"
   # shellcheck disable=SC2162
   read -s -n 1
}

select yn in "Yes" "No"; do
    case $yn in
        Yes ) generate_key; break;;
        No ) break;;
    esac
done

echo "OK to install the following ?"
echo ""
echo "◆ git"
echo "◆ homebrew"
echo "┠─ fzf"
echo "┠─ chezmoi"
echo "┠─ zoxide"
echo "┖─ yazi"
echo ""

install_git_homebrew()
{
  # git
  sudo apt -y install git
  # homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # -> Source it (only append to .bashrc and .zshrc if not already present)
  # shellcheck disable=SC2016
  grep -qF 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' "$HOME/.bashrc" \
    || (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> "$HOME/.bashrc"
  grep -qF 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' "$HOME/.zshrc" \
    || (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> "$HOME/.zshrc"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  # fzf
  brew install fzf
  # chezmoi
  brew install chezmoi
  # zoxide - smarter cd command
  brew install zoxide
  # yazi - terminal file manager
  brew install yazi
}

select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_git_homebrew; break;;
        No ) break;;
    esac
done

install_zsh()
{
  # Install lazygit
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
  LAZYGIT_ARCH=$(uname -m | sed 's/aarch64/arm64/;s/armv7l/armv7/')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit -D -t /usr/local/bin/
  rm -f lazygit.tar.gz lazygit
  # zsh
  sudo apt -y install zsh
  # oh my zsh
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  # powerlevel10k
  if ! command -v git &>/dev/null; then
    echo "Skipping powerlevel10k: git is not installed"
  else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
  fi
}

echo "OK to install the following ?"
echo ""
echo "◆ lazygit"
echo "◆ zsh"
echo "◆ ohmyzsh"
echo "┖─ powerlevel10k"
echo ""

select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_zsh; break;;
        No ) break;;
    esac
done

install_common()
{
  sudo apt -y install gnupg2 build-essential jq
}

echo "OK to install the following ?"
echo ""
echo "◆ gnupg2"
echo "◆ build-essential"
echo "◆ jq"
echo ""

select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_common; break;;
        No ) break;;
    esac
done

install_mise()
{
  if ! command -v brew &>/dev/null; then
    echo "Skipping mise: brew is not installed"
    return
  fi
  brew install mise
}

echo "OK to install the following ?"
echo ""
echo "◆ mise (from brew)"
echo ""

select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_mise; break;;
        No ) break;;
    esac
done

init_tmux_plugins()
{
  if ! command -v git &>/dev/null; then
    echo "Skipping tmux plugins: git is not installed"
    return
  fi
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

echo "OK to install tmux plugins ?"
echo ""
echo "◆ tmux-plugins/tpm"
echo ""
select yn in "Yes" "No"; do
    case $yn in
        Yes ) init_tmux_plugins; break;;
        No ) break;;
    esac
done


init_chezmoi()
{
  if ! command -v chezmoi &>/dev/null; then
    echo "Skipping chezmoi: chezmoi is not installed"
    return
  fi
  chezmoi init --ssh --apply "$GITHUB_USERNAME"
}

echo "OK to apply your chezmoi settings from github $GITHUB_USERNAME ?"
echo ""
select yn in "Yes" "No"; do
    case $yn in
        Yes ) init_chezmoi; break;;
        No ) break;;
    esac
done

install_fonts()
{
  # Fetch the latest Nerd Fonts release version
  NF_VERSION=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
  # Download the JetBrainsMono zip and extract only the NL Mono variants
  TMP_DIR=$(mktemp -d)
  curl -fsSLo "$TMP_DIR/JetBrainsMono.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v${NF_VERSION}/JetBrainsMono.zip"
  unzip -q -o "$TMP_DIR/JetBrainsMono.zip" 'JetBrainsMonoNLNerdFontMono-*.ttf' -d "$TMP_DIR"
  rm "$TMP_DIR/JetBrainsMono.zip"

  if grep -qi microsoft /proc/version 2>/dev/null; then
    # Running in WSL: install into the Windows per-user font directory
    # so the fonts are available to Windows terminals (e.g. Windows Terminal)
    WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
    FONT_DIR="/mnt/c/Users/${WIN_USER}/AppData/Local/Microsoft/Windows/Fonts"
  else
    FONT_DIR="$HOME/.local/share/fonts"
  fi
  mkdir -p "$FONT_DIR"
  cp "$TMP_DIR"/JetBrainsMonoNLNerdFontMono-*.ttf "$FONT_DIR/"
  rm -rf "$TMP_DIR"
  if ! grep -qi microsoft /proc/version 2>/dev/null; then
    # Rebuild the Linux font cache so the new fonts are immediately usable
    fc-cache -f
  fi
  echo "Fonts installed to $FONT_DIR"
}

echo "OK to install JetBrainsMonoNL Nerd Font Mono fonts ?"
echo ""
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_fonts; break;;
        No ) break;;
    esac
done

configure_wsl()
{
  if ! grep -qi microsoft /proc/version 2>/dev/null; then
    echo "Skipping WSL config: not running in WSL"
    return
  fi
  local username
  username=$(whoami)
  sudo tee /etc/wsl.conf > /dev/null <<EOF
[boot]
systemd=true

[user]
default=${username}
EOF
  echo "WSL configured. Run 'wsl --shutdown' from PowerShell then reopen the terminal."
}

echo "OK to configure WSL ? (sets default user, enables systemd)"
echo ""
echo "◆ /etc/wsl.conf"
echo ""

select yn in "Yes" "No"; do
    case $yn in
        Yes ) configure_wsl; break;;
        No ) break;;
    esac
done

echo ""
echo "Done! Restart your shell to apply all changes."
