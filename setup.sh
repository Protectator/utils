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
  sudo apt -y install wget curl make htop unzip vim tmux
}

echo "OK to install the following ?"
echo ""
echo "◆ wget"
echo "◆ curl"
echo "◆ make"
echo "◆ htop"
echo "◆ unzip"
echo "◆ vim"
echo "◆ tmux"
echo ""

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
read -r GITHUB_USERNAME

echo "e-mail address to use for SSH key and git ? (default: $EMAIL)"
read -r EMAIL

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
   ssh-keygen -t ed25519 -C \""$EMAIL"\"
   
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

echo "Updating apt..."
sudo apt update

echo "OK to install the following ?"
echo ""
echo "◆ git"
echo "◆ homebrew"
echo "┠─ fzf"
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
  # fzf
  brew install fzf
  # chezmoi
  brew install chezmoi
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
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit -D -t /usr/local/bin/
  # Download fonts
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
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

echo "OK to install tmux plugins ?"
echo ""
echo "◆ tmux-plugins/tpm"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) init_tmux_plugins; break;;
        No ) break;;
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
        No ) break;;
    esac
done
