
!#/bin/bash

# script to initialize the environment in Ubuntu 22.04 minimal on Oracle Cloud

# update the system
apt update
apt upgrade -y

# install essential packages
apt install -y git-all net-tools ca-certificates curl gnupg cmake unzip

# check if nvim has been installed, if not, install it
if ! [ -x "$(command -v nvim)" ]; then
	mkdir /run
	cd /run && git clone https://github.com/neovim/neovim
	cd neovim && git checkout stable
	make CMAKE_BUILD_TYPE=RelWithDebInfo

	cd build && cpack -G DEB && dpkg -i nvim-linux64.deb
fi

