#!/bin/bash
sudo apt-get install -y vim
echo "deb ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# setup
sudo apt-get install -y bison flex texinfo gawk automake subversion
sudo apt-get install -y gperf help2man make libtool libncurses5-dev 
sudo apt-get install -y gcj-jdk python-dev g++
git clone git://git.savannah.gnu.org/libtool.git
cd libtool
./configure; make; make install

# build crosstool-ng
git clone https://github.com/crosstool-ng/crosstool-ng.git
cd crosstool-ng
./bootstrap
./configure --prefix=/opt/crosstool-ng
make
make install
export PATH=$PATH:/opt/crsstool-ng/bin/

# check libs version
lld --version
gcc --version

# build toolchain
mkdir temp; cd temp
#ct-ng armv7-rpi2-linux-gnueabihf
cp ../croosng_config .config
ct-ng menuconfig
ct-ng build

