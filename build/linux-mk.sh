#!/bin/bash
arch=arm
toolchain=armv7-rpi2conan-linux-gnueabihf-
KERNEL=kernel7
src=/home/deb/work/kernel/src/
out=/home/deb/work/kernel/out/
img=/home/deb/work/kernel/img/

rm -rf $img*
mkdir -p $img/boot/overlays
#make -C $src ARCH=$arch CROSS_COMPILE=$toolchain O=$out clean
make -C $src ARCH=$arch CROSS_COMPILE=$toolchain mrproper

#make ARCH=$arch CROSS_COMPILE=$toolchain bcm2709_defconfig
make -C $src ARCH=$arch CROSS_COMPILE=$toolchain O=$out menuconfig
make -C $src ARCH=$arch CROSS_COMPILE=$toolchain O=$out -j4 zImage
make -C $src ARCH=$arch CROSS_COMPILE=$toolchain O=$out modules
make -C $src ARCH=$arch CROSS_COMPILE=$toolchain O=$out dtbs

make -C $src ARCH=$arch CROSS_COMPILE=$toolchain O=$out INSTALL_MOD_PATH=$img modules_install  >/dev/null 2>&1
$src/scripts/mkknlimg $out/arch/arm/boot/zImage $img/boot/$KERNEL.img
cp -raf $out/arch/arm/boot/dts/*.dtb $img/boot/
cp -raf $out/arch/arm/boot/dts/overlays/*.dtb* $img/boot/overlays/
cp -raf $src/arch/arm/boot/dts/overlays/README $img/boot/overlays/
tar zcvf img.tar.gz img/ >/dev/null 2>&1

