#!/usr/bin/env bash

ID=$(awk -F "=" '/DISTRIB_ID/{print $2}' /etc/lsb-release)
export ID

RELEASE=$(awk -F "=" '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
export RELEASE

CODENAME=$(awk -F "=" '/DISTRIB_CODENAME/{print $2}' /etc/lsb-release)
export CODENAME

# Setup stuff for initial setup
mkdir -p ${HOME}/{tmp,repos,.ssh,.config,bin,.local/bin} 2>/dev/null

sudo apt-get update --yes
sudo apt install --yes git make tmux curl wget keychain ssh-askpass

# Install Chezmoi and Starship
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir ${HOME}/bin

# Source the new profile
. ${HOME}/.profile

# Install packages and settings
#install-lxss-basic
#install-domain-tool
#install-git-latest
#install-emacs-snapshot
#install-net-stuff
#install-powershell
#install-fun-stuff
#install-jekyll
#install-keybase-full
#install-keybase-cli
#install-mailtools
#install-keepass
#install-docker-for-wsl
#install-syncthing

#get-bbk
get-base16
#get-powerline-fonts
#get-fonts
get-tmux-plugin-manager
