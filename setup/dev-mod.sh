#!/bin/bash
# Voice
sudo apt-get -y install espeak

# Dev Build
sudo apt-get -y install gcc make bc screen ncurses-dev

# Airmon
sudo apt-get install -y libpcap-dev libsqlite3-dev sqlite3 libpcap0.8-dev libssl-dev build-essential iw tshark libnl-dev ethtool

git clone https://github.com/aircrack-ng/aircrack-ng.git
cd aircrack-ng/
make
sudo make install
sudo airodump-ng-oui-update
cd ..

git clone https://github.com/gabrielrcouto/reaver-wps.git
cd reaver-wps/src
./configure
make
sudo make install


#Swift
wget http://repos.rcn-ee.com/debian/pool/main/r/rcn-ee-archive-keyring/rcn-ee-archive-keyring_2015.10.22~bpo90+20151022+1_all.deb
sudo dpkg -i rcn-ee-archive-keyring_2015.10.22~bpo90+20151022+1_all.deb
echo "deb [arch=armhf] http://repos.rcn-ee.com/debian/ jessie main" | sudo tee --append /etc/apt/sources.list
sudo apt-get -y update

sudo apt-get -y install libicu-dev
sudo apt-get -y install clang-3.6
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.6 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.6 100

wget -qO- http://dev.iachieved.it/iachievedit.gpg.key | sudo apt-key add -
echo "deb [arch=armhf] http://iachievedit-repos.s3.amazonaws.com/ jessie main" | sudo tee --append /etc/apt/sources.list
sudo apt-get -y update
sudo apt-get install -y swift-2.2

