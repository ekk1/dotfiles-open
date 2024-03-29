bash ./13.init.debian.server.sh

# Fonts
apt install fonts-noto-cjk fonts-noto-mono \
    fonts-noto-color-emoji fonts-noto-cjk-extra \
    fonts-font-awesome fonts-powerline \
    fonts-ubuntu-console

# GUI Tools
apt install gimp
apt install -t bookworm-backports yt-dlp
apt install mpv lm-sensors rfkill
apt install chromium neofetch virt-manager remmina fcitx5 fcitx5-chinese-addons
# apt install gnome-shell-extension-freon
# apt install firmware-linux
apt install mesa-utils inxi
apt install fcitx5 fcitx5-chinese-addons libsecret-tools
apt install foot foot-themes

# Sway
# apt install sway swaybg swayidle swaylock sway-backgrounds foot foot-themes dmenu wofi i3status i3blocks
# apt install grimshot gthumb

# Kernel building (mostly for Surface)
# apt install pahole build-essential binutils-dev libncurses5-dev libssl-dev ccache bison flex libelf-dev bc debhelper rsync
# for i in ~/linux-surface/patches/6.1/*.patch; do patch -p1 < $i; done
# ./scripts/kconfig/merge_config.sh <base-config> ~/linux-surface/configs/surface-5.10.confi
# make menuconfig
# make olddefconfig
# make -j `getconf _NPROCESSORS_ONLN` bindeb-pkg LOCALVERSION=-linux-surface
# dpkg -i linux-headers-[VERSION].deb linux-image-[VERSION].deb linux-libc-dev-[VERSION].deb

# Check the readme
# dpkg -L wireless-regdb

# Quick firewall and startup script
cat << EOF > /root/00-startup.sh
iptables -F
iptables -X
iptables -P INPUT DROP
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -P FORWARD DROP
EOF

# Quick firewall service
cat << EOF > /etc/systemd/system/sa-pc-startup.service
[Unit]
Description=Turn on firewall

[Service]
Type=oneshot
ExecStart=bash /root/00-startup.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable sa-pc-startup.service

# GPU Check
# inxi -G
# glxinfo
# switcheroolctl list

# PCI Passthrough
# vim /etc/default/grub
# GRUB_CMDLINE_LINUX="intel_iommu=on iommu=pt"
# update-grub
#
# Get the vendor id and device id for GPU
# lspci -nn | grep -i nvidia
#
# echo 'vfio-pci' > /etc/modules-load.d/vfio-pci.conf
# echo 'options vfio-pci ids=10de:1c03,10de:10f1' > /etc/modprobe.d/vfio.conf
# echo 'blacklist nouveau' > /etc/modprobe.d/blacklist-nouveau.conf
# echo 'options nouveau modeset=0' >> /etc/modprobe.d/blacklist-nouveau.conf
#
# sudo update-initramfs -u
#
# reboot
#
# Check for these things
# dmesg | grep -i iommu
# dmesg | grep -i vfio
#
# lspci -vv | less
# Search for NVIDIA and check if driver in use is vfio
#
# other libvirt tweaks
#
# Windows guest needs UEFI Firmware
# Its better to start installing without GPU first
# After done installing, add GPU and start again, wait for windows to download its own GPU driver, screen will not work for now
# After windows installed its driver, shutdown and set Virtual GPU to None, start again, and install latest driver from Nvidia
#
# Socket Core Thread setting needs to be exact
# lscpu -e
#
# <cputune> # Same level as <vcpu>
#   <vcpupin vcpu='0' cpuset='0'/>
#   <vcpupin vcpu='1' cpuset='1'/>
# </cputune>
#
# EvDev: Use same mouse and keyboard for guest and host
# ls -al /dev/input/by-id/xxx
# Only name with event will work, there might be more than 1
# Use cat /dev/input/by-id/xxx-event-xxx
# And move mouse or keyboard to check if this is the one
#
# Please note that if keyboard is disconnected when controlled by guest, there might be bugs that guest not able to grab it again, only reboot the guest seems work for now
#
# <input type="evdev">
#   <source dev="/dev/input/by-id/$YOURMOUSE-event-mouse"/>
# </input>
# <input type="evdev">
#   <source dev="/dev/input/by-id/$YOURKEYBOARD-event-kbd" grabToggle='ctrl-ctrl' grab="all" repeat="on"/>
# </input>
#
# Hide info for Nvidia Driver
#
#<features>
#  ...
#  <hyperv>
#    ...
#    <vendor_id state='on' value='randomid'/>
#    ...
#  </hyperv>
#  ...
#</features>
#
#<features>
#  ...
#  <kvm>
#    <hidden state='on'/>
#  </kvm>
#  ...
#</features>
#
#
