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

GITHUB_USERNAME=Protectator
EMAIL=me@kewindousse.ch

# Getting some info from the user
echo "GitHub username ? (default: $GITHUB_USERNAME)"
read -r GITHUB_USERNAME

echo "e-mail address to use for SSH key and git ? (default: $EMAIL)"
read -r EMAIL

ssh-keygen -t ed25519 -C \""$EMAIL"\"

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
  sudo apt -y install git-all
  # homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # -> Source it
  # shellcheck disable=SC2016
  (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/kewin/.bashrc
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
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
  # Download fonts
  FONTS_PATH
  echo "Downloading MesloLGS NF fonts in ~/fonts"
  mkdir -p fonts
  cd ~/fonts
  wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
  wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
  wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
  wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
  cd ~
  # zsh
  sudo apt -y install zsh
  # oh my zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  # powerlevel10k
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
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

install_common()
{
  sudo apt -y install wget curl make gnupg2 build-essential jq htop unzip
}

echo "OK to install the following ?"
echo ""
echo "◆ wget"
echo "◆ curl"
echo "◆ make"
echo "◆ gnupg2"
echo "◆ build-essential"
echo "◆ jq"
echo "◆ htop"
echo "◆ unzip"
echo ""

select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_common; break;;
        No ) ;;
    esac
done

install_nvm()
{
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
}

echo "OK to install the following ?"
echo ""
echo "◆ nvm"
echo ""

select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_nvm; break;;
        No ) ;;
    esac
done

init_chezmoi()
{
  sh -c "$(curl -fsLS get.chezmoi.io)" -- init --ssh --apply "$GITHUB_USERNAME"
}

echo "OK to apply your chezmoi settings from github $GITHUB_USERNAME ?"
echo ""
select yn in "Yes" "No"; do
    case $yn in
        Yes ) init_chezmoi; break;;
        No ) ;;
    esac
done
