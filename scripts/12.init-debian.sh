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
# maybe for laptop?
# apt install gnome-shell-extension-freon
# firmware linux is probably needed for desktop
apt install firmware-linux
apt install mesa-utils inxi
apt install fcitx5 fcitx5-chinese-addons libsecret-tools
apt install foot foot-themes

# Fcit5
# run fcitx5-configtool to add libpinyin
# run fcitx5 when OS start, this should be enough for native wayland apps like terminal
# although sometimes no input panel
# for chromium, add following file
# cat .config/gtk-4.0/settings.ini
#
# [Settings]
# gtk-im-module=fcitx
#
# and ensure im related env vars in the bashrc
# export GTK_IM_MODULE=fcitx
# export QT_IM_MODULE=fcitx
# export XMODIFIERS=@im=fcitx
#
# run chromium with
# chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4
#
# These should be for simple IM input experience, although sometimes there are no input panel
# for better exp, install this
#
# apt install gnome-shell-extension-kimpanel
#
# reboot OS, or kill gdm3 process, and run
#
# gnome-extensions enable kimpanel@kde.org
#
# you should have a mostly working setup!
#
# for vscode, running under wayland is not supported since GNOME doesn't support text-input-v1
# only way is run code without wayland, and it should run under X11, which is actually ok
# but one should notice that under fractional scaling, x11 apps will be kind of blurry

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

# NVIDIA and Wayland
# apt install linux-headers-amd64
# apt install build-essentials
# apt install nvidia-driver firmware-misc-nonfree
# echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX nvidia-drm.modeset=1"' > /etc/default/grub.d/nvidia-modeset.cfg
# update-grub
# check if services are installed, if using offical driver from website, these should already be installed
# apt install nvidia-suspend-common
# systemctl enable nvidia-suspend.service
# systemctl enable nvidia-hibernate.service
# systemctl enable nvidia-resume.service
# cat /proc/driver/nvidia/params | grep PreserveVideoMemoryAllocations
# this needs to be 1
# echo 'options nvidia NVreg_PreserveVideoMemoryAllocations=1' > /etc/modprobe.d/nvidia-power-management.conf

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
