#!/bin/bash
NGPATH="/opt/crosstool-ng/"
TARGET="armv7-rpi-linux-gnueabihf"

function build_libtool()
{
  #git clone git://git.savannah.gnu.org/libtool.git
  wget http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz
  tar xvf libtool-2.4.6.tar.gz
  cd libtool
  ./configure; make; sudo make install
}


function setup_for_debian()
{
  #sudo apt-get install -y vim
  echo "deb ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

  # setup for Debian
  sudo apt-get install -y bison flex texinfo gawk automake subversion
  sudo apt-get install -y gperf help2man make libtool libncurses5-dev
  sudo apt-get install -y gcj-jdk python-dev g++
}


function setup_for_ubuntu()
{
  # setup for Ubuntu
  sudo apt-get install -y sed bash cut dpkg-dev bison flex patch
  sudo apt-get install -y texinfo automake m4 libtool stat cvs
  sudo apt-get install -y websvn tar gzip bzip2 lzma readlink
  sudo apt-get install -y libncurses5-dev libtool gcj cvsd gawk
}


function setup_env()
{

  echo "export PATH=$PATH:${NGPATH}/bin/:/opt/${TARGET}/bin/" >> ~/.bashrc
      cd ~/${TARGET}/bin/
      PREFIX=${TARGET}-
      AFTFIX=arm-linux-
      ln -s ${PREFIX}gcc ${AFTFIX}gcc
      ln -s ${PREFIX}addr2line ${AFTFIX}addr2line
      ln -s  ${PREFIX}gdbtui ${AFTFIX}gdbtui
      ln -s  ${PREFIX}ar ${AFTFIX}ar
      ln -s  ${PREFIX}as ${AFTFIX}as
      ln -s  ${PREFIX}c++ ${AFTFIX}c++
      ln -s  ${PREFIX}c++filt ${AFTFIX}c++filt
      ln -s  ${PREFIX}cpp ${AFTFIX}cpp
      ln -s  ${PREFIX}g++ ${AFTFIX}g++
      ln -s  ${PREFIX}gccbug ${AFTFIX}gccbug
      ln -s  ${PREFIX}gcj ${AFTFIX}gcj
      ln -s  ${PREFIX}gcov ${AFTFIX}gcov
      ln -s  ${PREFIX}gdb ${AFTFIX}gdb
      ln -s  ${PREFIX}gfortran ${AFTFIX}gfortran
      ln -s  ${PREFIX}gprof ${AFTFIX}gprof
      ln -s  ${PREFIX}jcf-dump ${AFTFIX}jcf-dump
      ln -s  ${PREFIX}ld ${AFTFIX}ld
      ln -s  ${PREFIX}ldd ${AFTFIX}ldd
      ln -s  ${PREFIX}nm ${AFTFIX}nm
      ln -s  ${PREFIX}objcopy ${AFTFIX}objcopy
      ln -s  ${PREFIX}objdump ${AFTFIX}objdump
      ln -s  ${PREFIX}populate ${AFTFIX}populate
      ln -s  ${PREFIX}ranlib ${AFTFIX}ranlib
      ln -s  ${PREFIX}readelf ${AFTFIX}readelf
      ln -s  ${PREFIX}run ${AFTFIX}run
      ln -s  ${PREFIX}size ${AFTFIX}size
      ln -s  ${PREFIX}strings ${AFTFIX}strings
      ln -s  ${PREFIX}strip ${AFTFIX}strip
	sudo mv ~/$TARGET/ /opt/
}



function build_toolchain()
{
# build crosstool-ng
git clone https://github.com/crosstool-ng/crosstool-ng.git
cd crosstool-ng
./bootstrap
./configure --prefix=$NGPATH
#./configure
make
sudo make install
cd ../
# check libs version
#ldd --version; gcc --version; uname -a
# check in rpi3b: glibc-2.19, gcc-4.9.2, kernel-4.4.14

# build toolchain
#ct-ng armv7-rpi2-linux-gnueabihf
cp crossng_rpi_config .config
${NGPATH}/bin/ct-ng menuconfig
sudo ${NGPATH}/bin/ct-ng build
}


setup_for_ubuntu
#setup_for_debian
build_toolchain
setup_env

