#!/bin/bash
modprobe nbd max_part=8
qemu-nbd --connect=/dev/nbd0 $1
fdisk /dev/nbd0 -l
mkdir -p /mnt/rescue
mount /dev/nbd0p1 /mnt/rescue/

# umount /mnt/rescue
# qemu-nbd --disconnect /dev/nbd0
# rmmod nbd
