#!/bin/bash
# I2C
sudo apt-get -y install python-smbus
sudo apt-get -y install i2c-tools

# GPIO
sudo apt-get -y install python-rpi.gpio

# UART
sudo apt-get -y install python-serial
FILE=/boot/cmdline.txt
sudo mv $FILE $FILE-bak
echo "dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline
fsck.repair=yes rootwait" | sudo tee $FILE

# Bluetooth
sudo apt-get -y install bluez pulseaudio-module-bluetooth python-gobject python-gobject-2 
sudo apt-get -y install bluez-tools bluetooth blueman
