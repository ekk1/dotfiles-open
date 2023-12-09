find . | cpio -H newc -o | gzip > /boot/initramfs-rescue.img
