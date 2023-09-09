## Install linux

```bash
# Sync time
timedatectl

# Format disk
fdisk -l
fdisk /dev/sdX

# layout:
# GPT + 500M EFI Part + remaining part
# EFI part is 1

mkfs.btrfs /dev/sdX2
mkfs.fat -F 32 /dev/sdX1

mount /dev/sdX2 /mnt
mount --mkdir /dev/sdX1 /mnt/boot

vim /etc/pacman.d/mirrorlist

pacstrap -K /mnt base base-devel linux linux-firmware vim git

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Region/City /etc/localtime

hwclock --systohc

vim /etc/locale.gen

locale-gen

vim /etc/locale.conf
LANG=en_US.UTF-8

vim /etc/hostname
xxx

passwd root

pacman -S grub
pacman -S efibootmgr

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

pacman -S intel-ucode
grub-mkconfig -o /boot/grub/grub.cfg


```
