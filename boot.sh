#!/usr/bin/env bash

export ID=$(awk -F "=" '/DISTRIB_ID/{print $2}' /etc/lsb-release)
export RELEASE=$(awk -F "=" '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
export CODENAME==$(awk -F "=" '/DISTRIB_CODENAME/{print $2}' /etc/lsb-release)

# Setup stuff for initial setup

mkdir ~/tmp ~/bin ~/repos ~/.ssh ~/.gnupg

sudo apt install --yes git make tmux
git clone --depth 1 https://github.com/sdaaish/boot.git ~/repos/boot
git clone --depth 1 https://github.com/sdaaish/dotfiles.git ~/.config/dotfiles

make -C ~/.config/dotfiles

# Source the new profile
. ~/.profile

# Install packages and settings
install-emacs-d
install-emacs-snapshot
install-git-latest
#install-lxss-basic
install-domain-tool
#install-net-stuff
#install-fun-stuff
install-powershell
#install-jekyll
#install-keybase-full
install-keybase-cli
#install-mailtools
#install-keepass
#install-docker-for-wsl
#install-syncthing

#get-bbk
get-base16
get-powerline-fonts
get-tmux-plugin-manager
