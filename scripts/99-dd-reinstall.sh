[ "$EUID" -ne 0 ] && echo "Not running as root. Exiting." && exit 1

mkdir -p initramfs/{bin,dev,etc,lib,proc,root,sbin,sys,usr}
cd initramfs
mkdir -p usr/{bin,sbin}

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

cat << EOF > init
#!/bin/busybox sh
mount -t proc none /proc
mount -t sysfs none /sys
# load modules that are present on this machine helps
# maybe can be trimmed down a little
# (currently uses 300MB+)
# modprobe xxx
mount -t devtmpfs none /dev
mdev -s
/bin/sh
EOF

chmod +x init

# mkdir -p lib/modules/$(uname -r)/kernel/drivers/{ata,scsi,}
mkdir -p lib/modules
cp -r /lib/modules/$(uname -r) lib/modules/

find . | cpio -H newc -o | gzip > /boot/initramfs-rescue.img
ROOT_UUID=$(lsblk -f | grep /$ | awk '{print $3}')
LINUX_IMAGE=$(ls /boot/ | grep vmlinuz | tail -1)
cp /boot/${LINUX_IMAGE} /boot/vmlinuz-rescue

# for btrfs
# insmod btrfs
# linux /@rootfs/boot
cat << EOF >> /etc/grub.d/40_custom
menuentry "MyRR" {
    insmod ext2
    search --no-floppy --fs-uuid --set=root $ROOT_UUID
    linux /boot/vmlinuz-rescue rw
    initrd /boot/initramfs-rescue.img
}
EOF

chmod +x /etc/grub.d/40_custom
sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT="MyRR"/g' /etc/default/grub

# maybe use this to reboot
# echo b > /proc/sysrq-trigger
# update-grub
