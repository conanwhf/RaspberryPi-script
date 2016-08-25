#!/bin/sh

#mount USB device
usbmount=/mnt
mkdir -p $usbmount
if [ -z $1 ]; then
	echo "no argument, assume the mount device is /dev/sda1 ? Y/N"
	read key
	if [ "$key" = "y" -o "$key" = "Y" ]; then
		sudo mount -t vfat -o uid=1000 /dev/sda1 $usbmount
	else
		echo "$0 [backup dest device name], e.g. $0 /dev/sda1"
		exit 0
	fi
else
	sudo mount -t vfat -o uid=1000 $1 $usbmount
fi
if [ -z "`grep $usbmount /etc/mtab`" ]; then
	echo "mount fail, exit now"
	exit 0
fi 

img=$usbmount/iNovaBear-`date +%Y%m%d-%H%M`.img
#img=$usbmount/rpi.img

#install tools
#sudo apt-get -y install dosfstools dump parted kpartx
sudo apt-get -y install rsync dosfstools parted kpartx


echo ===================== part 1, create a new blank img ===============================
# New img file
#sudo rm $img
bootsz=`df -P | grep /boot | awk '{print $2}'`
rootsz=`df -P | grep /dev/root | awk '{print $3}'`
totalsz=`echo $bootsz $rootsz | awk '{print int(($1+$2)*1.3)}'`
sudo dd if=/dev/zero of=$img bs=1K count=$totalsz

# format virtual disk
bootstart=`sudo fdisk -l /dev/mmcblk0 | grep mmcblk0p1 | awk '{print $2}'`
bootend=`sudo fdisk -l /dev/mmcblk0 | grep mmcblk0p1 | awk '{print $3}'`
rootstart=`sudo fdisk -l /dev/mmcblk0 | grep mmcblk0p2 | awk '{print $2}'`
echo "boot: $bootstart >>> $bootend, root: $rootstart >>> end"
#rootend=`sudo fdisk -l /dev/mmcblk0 | grep mmcblk0p2 | awk '{print $3}'`
sudo parted $img --script -- mklabel msdos
sudo parted $img --script -- mkpart primary fat32 ${bootstart}s ${bootend}s
sudo parted $img --script -- mkpart primary ext4 ${rootstart}s -1
loopdevice=`sudo losetup -f --show $img`
device=/dev/mapper/`sudo kpartx -va $loopdevice | sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1`
sleep 5
sudo mkfs.vfat ${device}p1 -n boot
sudo mkfs.ext4 ${device}p2


echo ===================== part 2, fill the data to img =========================
# mount partitions
mountb=$usbmount/backup_boot/
mountr=$usbmount/backup_root/
mkdir -p $mountb $mountr
# backup /boot
sudo mount -t vfat ${device}p1 $mountb
sudo cp -rfp /boot/* $mountb
sync 
sudo umount $mountb
echo "...Boot partition done"
# backup /root
sudo mount -t ext4 ${device}p2 $mountr
if [ -f /etc/dphys-swapfile ]; then
        SWAPFILE=`cat /etc/dphys-swapfile | grep ^CONF_SWAPFILE | cut -f 2 -d=`
	if [ "$SWAPFILE" = "" ]; then
		SWAPFILE=/var/swap
	fi
	EXCLUDE_SWAPFILE="--exclude $SWAPFILE"
fi
sudo rsync --force -rltWDEgopt --delete \
	$EXCLUDE_SWAPFILE \
	--exclude '.gvfs' \
	--exclude '/dev' \
        --exclude '/media' \
	--exclude '/mnt' \
	--exclude '/proc' \
        --exclude '/run' \
	--exclude '/sys' \
	--exclude '/tmp' \
        --exclude 'lost\+found' \
	--exclude '$usbmount' \
	// $mountr
# special dirs 
for i in dev media mnt proc run sys boot; do
	if [ ! -d $mountr/$i ]; then
		sudo mkdir $mountr/$i
	fi
done
if [ ! -d $mountr/tmp ]; then
	sudo mkdir $mountr/tmp
	sudo chmod a+w $mountr/tmp
fi
sudo rm -f $mountr/etc/udev/rules.d/70-persistent-net.rules

sync 
ls -lia $mountr/home/pi/
sudo umount $mountr
echo "...Root partition done"
# if using the dump/restore 
# tmp=$usbmount/root.ext4
# sudo chattr +d $img $mountb $mountr $tmp
# sudo mount -t ext4 ${device}p2 $mountr
# cd $mountr
# sudo dump -0uaf - / | sudo restore -rf -
# cd

# umount loop device
sudo kpartx -d $loopdevice
sudo losetup -d $loopdevice
sudo umount $usbmount
rm -rf $mountb $mountr
echo "==== All done. You can un-plug the backup device"

