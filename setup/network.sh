#!/bin/bash
# IP
sudo cp interfaces /etc/network/interfaces
sudo systemctl daemon-reload
sudo service networking restart

# VNC
sudo apt-get -y install tightvncserver
sudo apt-get -y install xfonts-base
vncpasswd
sudo cp tightvncserver /etc/init.d/tightvncserver
sudo chmod +x /etc/init.d/tightvncserver
sudo update-rc.d tightvncserver defaults

# Manually Config
echo "Please run the default config tool!(change password, exter disk)"
echo "Please run the default config tool!(change password, exter disk)"
echo "Please run the default config tool!(change password, exter disk)"
echo "Please run the default config tool!(change password, exter disk)"

sudo raspi-config

