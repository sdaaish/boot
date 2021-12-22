#!/usr/bin/env bash

ID=$(awk -F "=" '/DISTRIB_ID/{print $2}' /etc/lsb-release)
export ID

RELEASE=$(awk -F "=" '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
export RELEASE

CODENAME=$(awk -F "=" '/DISTRIB_CODENAME/{print $2}' /etc/lsb-release)
export CODENAME

# Setup stuff for initial setup
mkdir ${HOME}/{tmp,repos,.ssh,.config} 2>/dev/null

sudo apt-get update --yes
sudo apt install --yes git make tmux stow curl wget keychain ssh-askpass
git clone --depth 1 https://github.com/sdaaish/boot.git ${HOME}/repos/boot
git clone --depth 1 https://github.com/sdaaish/dotfiles.git ${HOME}/.config/dotfiles

rm ${HOME}/.bash*
rm ${HOME}/.profile

cd ${HOME}/.config/dotfiles || exit
./setup.sh

# Source the new profile
. ${HOME}/.profile

# Install packages and settings
install-lxss-basic
install-domain-tool
install-git-latest
install-emacs-snapshot
#install-net-stuff
install-powershell
install-fun-stuff
#install-jekyll
#install-keybase-full
#install-keybase-cli
#install-mailtools
#install-keepass
#install-docker-for-wsl
#install-syncthing

#get-bbk
get-base16
get-powerline-fonts
get-tmux-plugin-manager
