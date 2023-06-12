apt-get install cryptsetup

# /dev/xxx can be a single file
# fallocate -l 10G vault-file

cryptsetup -y -v luksFormat /dev/xxx
cryptsetup -y -v --type luks2 luksFormat /dev/xxx

cryptsetup luksOpen /dev/xxx backup2

# check status with this
cryptsetup -v status backup2
cryptsetup luksDump /dev/xxx

# If possible, you should fill device with zeros first
# this is ensure outsider can't see data size pattern
dd if=/dev/zero of=/dev/mapper/backup2 status=progress

mkfs.ext4 /dev/mapper/backup2

umount /backup2
cryptsetup luksClose backup2
