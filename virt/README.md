## Useful QEMU flags

TODO:

1. create linux transparent router for windows guest
    1. finish connecting two servers
    2. problems with dns query from windows
    3. linux box can use redsocks to redirect tcp/udp traffic to socks5 proxy


```bash
# Run this as root to create image dir
./00.prepare.image.sh

# Prepare cloud init iso
./03.generate.ssh.key.sh
./09.prepare.iso.sh

# Create linux os disk
# rr means create disk in ram
./01.create.disk.sh /srv/vms/xxxx [rr]

# Create empty windows disk (for first time install)
./02.create.windows.disk.sh
# After install, rename it to windows.base
# Create qcow2 disk on this windows disk
# Do note that windows qcow2 disk's size will increase rapidly
# Not recommanded for small ram (those below 128G)
./02.create.windows.disk.sh /srv/vms/windows.base [rr]

# Create linux
./11.create.server.sh [rr]

# Create windows
./12.create.windows.sh [rr]

# Check linux up
./22-connect-console.sh
# Clear SSH key
./29.clear.ssh.fingerprint.sh
# Copy scripts and config
./91.copy.init.scripts.sh
./92.copy.dev.config.sh
# SSH into vm
./21-ssh-to-vm.sh

# Connect windows vnc
./24.connect.windows.vnc.sh

# Run others in vm
./93.init.debian.root.sh
./94.init.debian.user.sh


# Listing vm and files
./31.list.vm.sh
./32.list.dir.sh
# Delete all disks (remember to backup needed disk!!!)
./99.delete.disk.sh

```



```bash
# Performance related
    # -enable-kvm \
    # -m 32G -smp 8 \

# Create a netshare nic, hosting server will use listen, other servers use connect to join the same network
    # -netdev socket,id=netshare,listen=127.0.0.1:3333 \
    # -netdev socket,id=netshare,connect=127.0.0.1:3333 \
    # -device virtio-net,netdev=netshare \

# Use unix socket for monitor, and how to connect to it
    # -monitor unix:/tmp/monitor.sock,server,nowait \
    # nc -U /tmp/monitor.sock

# PCI passthrough
    # -device vfio-pci,host=07:00.0
    # -cpu host,kvm=off
    # -enable-kvm

# Prepare GPU passthrough

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
# CHECK scripts/12.init-debian.sh !!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#

vi /etc/default/grub

# Add
GRUB_CMDLINE_LINUX="intel_iommu=on iommu=pt"

grub-mkconfig -o /boot/grub/grub.cfg
# or
update-grub

lspci -nn | grep -i nvidia

vi /etc/modprobe.d/vfio.conf

# Add
options vfio-pci ids=10de:1c03,10de:10f1

echo 'vfio-pci' > /etc/modules-load.d/vfio-pci.conf

# Check
dmesg | grep -E "DMAR|IOMMU"
dmesg | grep -i vfio
lspci -vv | less
lspci -nnk -d 10de:13c2

# Maybe need
/etc/modprobe.d/blacklist.conf
blacklist nouveau

```
