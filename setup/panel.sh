echo "# HDMI panel setting" | sudo tee -a /boot/config.txt
echo "hdmi_group=2" | sudo tee -a /boot/config.txt
echo "hdmi_mode=87" | sudo tee -a /boot/config.txt
echo "hdmi_cvt 800 480 60 6 0 0 0" | sudo tee -a /boot/config.txt
echo "hdmi_drive=1" | sudo tee -a /boot/config.txt

sudo apt-get install -y xserver-xorg-input-evdev
sudo cp -rf /usr/share/X11/xorg.conf.d/10-evdev.conf
/usr/share/X11/xorg.conf.d/45-evdev.conf

wget http://www.waveshare.net/w/upload/3/37/Xinput-calibrator_0.7.5-1_armhf.zip
unzip Xinput-calibrator_0.7.5-1_armhf.zip
sudo dpkg -i -B input-calibrator_0.7.5-1_armhf/xinput-calibrator_0.7.5-1_armhf.deb

