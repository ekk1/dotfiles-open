## Useful QEMU flags

```bash
# Run this as root to create image dir
./00.prepare.image.sh

# Prepare cloud init iso
./02.generate.ssh.key.sh
./09.prepare.iso.sh

# Create data disk
./01.create.disk.sh /srv/vms/xxxx rr

# Create linux
./11.create.server.sh rr

# Clear SSH key
./29.clear.ssh.fingerprint.sh

# Copy scripts and config
./91-init-debian-nocloud.sh
./98.copy.dev.config.sh
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
