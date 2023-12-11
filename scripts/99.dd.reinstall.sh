[ "$EUID" -ne 0 ] && echo "Not running as root. Exiting." && exit 1

DISK_IMAGE="$1"

if [[ -z DISK_IMAGE ]]; then
    echo "Disk image is needed"
fi

if [[ ! -f DISK_IMAGE ]]; then
    echo "Disk image $DISK_IMAGE is not present"
fi

echo "Using $DISK_IMAGE as recover disk"

echo "Making initramfs"
mkdir -p initramfs/{bin,dev,etc,lib,proc,root,sbin,sys,usr}
cd initramfs
mkdir -p usr/{bin,sbin}

echo "Installing busybox"
apt install busybox-static
cp /usr/bin/busybox bin/
cd bin
for tool in $(./busybox --list); do ln -s busybox $tool ; done
cd ..

ldd bin/busybox

# Maybe this is not needed?
# i think mdev -s will create this, pending test
cd dev
mknod -m 660 console c 5 1
mknod -m 660 null c 1 3
mknod -m 660 tty c 5 0
cd ..

echo "Generating init script"
cat << EOF > init
#!/bin/busybox sh
mount -t proc none /proc
mount -t sysfs none /sys
# load modules that are present on this machine helps
# maybe can be trimmed down a little
# (currently uses 300MB+)
# modprobe xxx
$(for ii in $(lsmod  | awk '{print $1}') ; do echo "modprobe $ii" ; done)
mount -t devtmpfs none /dev
mdev -s
dd if=recover.img of=/dev/$(lsblk -oMOUNTPOINT,PKNAME -P -M | grep 'MOUNTPOINT="/"' | tr " " "\n" | grep PKNAME | awk -F'"' '{print $2}' | sed 's/[0-9]*$//') bs=4M
sync
/bin/sh
echo b > /proc/sysrq-trigger
EOF

chmod +x init

echo "Copying modules"
# mkdir -p lib/modules/$(uname -r)/kernel/drivers/{ata,scsi,}
mkdir -p lib/modules
cp -r /lib/modules/$(uname -r) lib/modules/

echo "Copying recover disk image"
cp $DISK_IMAGE recover.img

echo "Packing initramfs"
find . | cpio -H newc -o | gzip > /boot/initramfs-rescue.img

echo "Backing up kernel image"
cp /boot/vmlinuz-$(uname -r) /boot/vmlinuz-rescue

echo "Generating grub config"
# for btrfs
# insmod btrfs
# linux /@rootfs/boot
ROOT_PART=$(df /boot/ | grep -v Filesystem | awk '{print $1}')
ROOT_UUID=$(blkid | grep ${ROOT_PART} | tr " " "\n" | grep ^UUID= | awk -F'"' '{print $2}')
cat << EOF >> /etc/grub.d/40_custom
menuentry "MyRR" {
    insmod ext2
    search --no-floppy --fs-uuid --set=root $ROOT_UUID
    linux /boot/vmlinuz-rescue rw
    initrd /boot/initramfs-rescue.img
}
EOF

echo "Marking current initramfs as default"
chmod +x /etc/grub.d/40_custom
sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT="MyRR"/g' /etc/default/grub

# maybe use this to reboot
echo "Updating grub"
update-grub

echo "Finished prepring, please check your config and reboot"
echo "  Maybe check following places"
echo "  /boot"
echo "  initramfs/lib"
echo "  initramfs/recover.img"
echo "  initramfs/init"
echo "  /etc/default/grub"
echo "  /etc/grub.d/40_custom"
