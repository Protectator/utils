#!/bin/bash
set -e

# This assumes we're on a fresh new install of a Debian/Ubuntu distro

# Don't run if root
if [ "$(id -u)" = "0" ]; then
   echo "This script must not be run as root" 1>&2
   exit 1
fi

GITHUB_USERNAME=Protectator
EMAIL=me@kewindousse.ch

# Getting some info from the user
echo "GitHub username ? (default: $GITHUB_USERNAME)"
read GITHUB_USERNAME

echo "e-mail address to use for SSH key and git ? (default: $EMAIL)"
read EMAIL

# ssh-keygen -t ed25519 -C \""$EMAIL"\"

echo "Updating apt..."
sudo apt update

echo "You can add the public key to your trusted keys in Github : https://github.com/settings/ssh/new"
echo "Here it is : "
echo ""
cat ~/.ssh/id_ed25519.pub
echo ""

echo "OK to install the following ?"
echo ""
echo "◆ git"
echo "◆ homebrew"
echo "┠─ fzf"
echo "┠─ lazygit"
echo "┖─ chezmoi"
echo ""

install_git_homebrew()
{
  # git
  sudo apt install git-all
  # homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # - lazygit
  brew install jesseduffield/lazygit/lazygit
  # fzf
  brew install fzf
  # chezmoi
  brew install chezmoi
}

select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_git_homebrew; break;;
        No ) ;;
    esac
done

install_zsh()
{
  # zsh
  sudo apt install zsh
  # oh my zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  # powerlevel10k
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
}

echo "OK to install the following ?"
echo ""
echo "◆ zsh"
echo "◆ ohmyzsh"
echo "┖─ powerlevel10k"
echo ""

select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_zsh; break;;
        No ) ;;
    esac
done

init_chezmoi()
{
  sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
}

echo "OK to apply your chezmoi settings from github $GITHUB_USERNAME ?"
echo ""
select yn in "Yes" "No"; do
    case $yn in
        Yes ) init_chezmoi; break;;
        No ) ;;
    esac
done
