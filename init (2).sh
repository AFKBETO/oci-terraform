# script to initialize the environment in Ubuntu 22.04 minimal on Oracle Cloud

# clean up the system firewalls
## check if the firewall has been cleaned, if not, clean it
if [ -f /home/ubuntu/.cache/.firewall_cleaned ]; then
	echo "Firewall has been cleaned"
else
	## save existing rules
	sudo iptables-save > ~/iptables-rules

	## modify rules, remove drop and reject lines
	grep -v "DROP" iptables-rules > tmpfile && mv tmpfile iptables-rules-mod
	grep -v "REJECT" iptables-rules-mod > tmpfile && mv tmpfile iptables-rules-mod

	## apply the modifications
	sudo iptables-restore < ~/iptables-rules-mod
	## check
	sudo iptables -L
	## save the changes
	sudo netfilter-persistent save
	sudo systemctl restart iptables

	touch /home/ubuntu/.cache/.firewall_cleaned
fi

# update the system
sudo apt update
sudo apt upgrade -y

# install essential packages
sudo apt install -y git-all net-tools ca-certificates curl gnupg uidmap ninja-build gettext cmake unzip

# check if docker has been installed, if not, install it
if [ -x "$(command -v docker)" ]; then
	echo "Docker has been installed"
else
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	sudo chmod a+r /etc/apt/keyrings/docker.gpg

	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
		$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	sudo apt-get update

	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
	
	# if rootless docker script does not exist, download it
	if [ ! -f /usr/bin/dockerd-rootless-setuptool.sh ]; then
		sudo apt install -y docker-ce-rootless-extras
	fi
	dockerd-rootless-setuptool.sh install

	# verify that Docker Engine is installed correctly by running the hello-world image
	docker run hello-world
	if [ $? -eq 0 ]; then
		echo "Docker has been installed successfully"
	else
		echo "Docker installation failed"
	fi

	docker system prune -a -f

	sudo systemctl enable docker.service
	sudo systemctl enable containerd.service
fi

# check if nvim has been installed, if not, install it
if ! [ -x "$(command -v nvim)" ]; then
	cd ~
	git clone https://github.com/neovim/neovim
	cd neovim && git checkout stable
	make CMAKE_BUILD_TYPE=RelWithDebInfo

	cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb
fi

# check if go has been installed, if not, install it

if ! [ -x "$(command -v go)" ]; then
	cd ~
	curl -L -o go.tar.gz https://go.dev/dl/go1.21.6.linux-arm64.tar.gz
	sudo rm -rf /usr/local/go && tar -C /usr/local -xzf go.tar.gz
	echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile
	source ~/.profile
fi
