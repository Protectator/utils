# Should be logged in as root
# To install this script, run :
#
# wget -O new-install.sh https://github.com/Protectator/utils/new-install.sh && bash new-install.sh

# Only run if root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# ----- Start of install -----

# Ask for pass for user and SSH key
read -s -p "Enter a pass for the user protectator:" pswd

#######
# Users
useradd protectator --home /home/protectator/ --create-home --groups sudo


##################
# Install software

# Repositories I trust
add-apt-repository ppa:git-core/ppa
add-apt-repository ppa:lazygit-team/release

apt-get update

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh | bash
# git
apt-get install -y git
# lazygit
apt-get install -y git lazygit


#############
# Set home up
su protectator
cd ~
mkdir -p /home/protectator/.ssh
mkdir projects
cd projects
git clone https://github.com/Protectator/utils.git
cd ~


########
# Access
curl https://github.com/Protectator.keys >> ~/.ssh/authorized_keys
echo -e "$pswd\n$pswd" | passwd
yes "y" | ssh-keygen -t rsa -b 4096 -C "me@protectator.ch"


####################
# node & npm install
nvm install --lts
nvm use --lts
npm install -g npx tldr


#######################################
# Erasing the password entered variable
export pswd=
