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
sudo mknod -m 660 console c 5 1
sudo mknod -m 660 null c 1 3
sudo mknod -m 660 tty c 5 0
cd ..

cat << EOF > init
#!/bin/busybox sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
# insmod /lib/modules/$(uname -r)/kernel/drivers/net/your_driver.ko
# or
# modprobe your_driver
# mdev -s

/bin/sh
EOF

chmod +x init
find . | cpio -H newc -o | gzip > /boot/initramfs-rescue.img
sudo cp /path/to/custom/kernel /boot/vmlinuz-rescue
sudo cp /path/to/custom/initramfs /boot/initramfs-rescue.img

cat << EOF >> /etc/grub.d/40_custom
menuentry "My Custom Rescue System" {
    insmod ext2
    search --no-floppy --fs-uuid --set=root xxxx
    linux /boot/vmlinuz-rescue rw
    initrd /boot/initramfs-rescue.img
}
EOF

sudo chmod +x /etc/grub.d/40_custom
# chane /etc/default/grub
# GRUB_DEFAULT="My Custom Rescue System"
update-grub
