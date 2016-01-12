sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo rpi-update

# vi
sudo apt-get -y remove vim-common
sudo apt-get -y install vim
# Chinese
sudo apt-get -y install ttf-wqy-zenhei ttf-wqy-microhei
sudo apt-get -y install fcitx fcitx-googlepinyin fcitx-module-cloudpinyin fcitx-sunpinyin
sudo "LC_ALL=\"en_US.UTF-8\" "  >> /etc/environment
sudo "LANG=\”en_US_.UTF-8\" " >> /etc/environment
# USB
sudo echo "#USB\nmax_usb_current=1" >> /boot/config.txt
# Samba
sudo apt-get -y install samba
sudo echo "[pi]\ncomment = Conan file space\path = \/home\/pi\/work\nread only = no\n public = yes" >> /etc/samba/smb.conf
sudo /etc/init.d/samba restart
# SSH
sudo echo "ClientAliveInterval 60\nClientAliveCountMax 2\n" >> /etc/ssh/sshd_config
# zip
sudo apt-get -y install zip

# Done
echo "You need a reboot!"
echo "You need a reboot!"
echo "You need a reboot!"
echo "You need a reboot!"
echo "You need a reboot!"
