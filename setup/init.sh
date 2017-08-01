#!/bin/bash
function update()
{
  	sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
	sudo cp sources.list /etc/apt/sources.list
	sudo apt-get -y update
	sudo apt-get -y upgrade
	sudo apt-get -y dist-upgrade
	sudo rpi-update
}

function base()
{
	# vi
	sudo apt-get -y remove vim-common
	sudo apt-get -y install vim
	cp vimrc ~/.vimrc
	# IP
	sudo cp interfaces /etc/network/interfaces
	sudo systemctl daemon-reload
	sudo service networking restart
	# Chinese
	sudo apt-get -y install ttf-wqy-zenhei ttf-wqy-microhei
	sudo apt-get -y install fcitx fcitx-googlepinyin fcitx-module-cloudpinyin fcitx-sunpinyin
	#echo LC_ALL="en_US.UTF-8" | sudo tee -a  /etc/environment
	#echo LANG="en_US.UTF-8" | sudo tee -a /etc/environment
	# USB
	echo "# USB Voltage" | sudo tee -a /boot/config.txt
	echo "max_usb_current=1" | sudo tee -a /boot/config.txt
	# SSH
	echo "ClientAliveInterval 60" | sudo tee -a /etc/ssh/sshd_config
	echo "ClientAliveCountMax 2" | sudo tee -a /etc/ssh/sshd_config
	# zip
	sudo apt-get -y install zip
	# ssh key
	ssh-keygen -t rsa -C "conan.whf@gmail.com" -b 4096
}

function samba()
{
# Samba
sudo apt-get -y install samba
echo "[pi]" | sudo tee -a /etc/samba/smb.conf
echo "comment = Conan file space" | sudo tee -a /etc/samba/smb.conf
echo "path = /home/pi/work" | sudo tee -a /etc/samba/smb.conf
echo "read only = no" | sudo tee -a /etc/samba/smb.conf
echo "public = yes" | sudo tee -a /etc/samba/smb.conf
sudo /etc/init.d/samba restart
}

function dev()
{
	# Voice
	sudo apt-get -y install espeak
	# Dev Build
	sudo apt-get -y install gcc make bc screen ncurses-dev
	# database
	sudo apt-get -y install sqlite3
	# xml
	sudo apt-get -y install libxml2-dev
}


#------------main
update
base
dev
#samba

# Done
echo "You need a reboot!"
echo "You need a reboot!"
echo "You need a reboot!"
echo "You need a reboot!"
echo "You need a reboot!"
