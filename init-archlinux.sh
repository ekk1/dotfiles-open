# Cli tools
pacman -S \
    vim tmux tree git htop man-db \
    nfs-utils smartmontools ranger \
    chrony dhcpcd dolphin ntfs-3g lsof \
    tig ncdu rsync btrfs-progs unrar p7zip python openbsd-netcat

pacman -S powerline powerline-fonts

# GUI
pacman -S \
    sway swaybg swayidle swaylock foot dmenu gammastep \
    xorg-xwayland qt5-wayland qt6-wayland qt5ct \
    polkit pipewire-pulse pavucontrol \
    i3blocks i3status intel-gpu-tools \
    intel-media-driver mpv libva-utils \
    chromium firefox hyprland

# Fonts
pacman -S \
    adobe-source-han-sans-cn-fonts \
    adobe-source-han-serif-cn-fonts \
    ttf-ubuntu-mono-nerd \
    noto-fonts-cjk

# Laptop may needs
pacman -S \
    brightnessctl \
    upower \
    iwd

# KVM
pacman -S \
    qemu-full libvirt virt-manager \
    dnsmasq dmidecode ovmf remmina

# GUI Extra
pacman -S libreoffice-fresh gimp lollypop
pacman -S fcitx fcitx-libpinyin

# gammastep -O 4500K
# showmount -e 192.168.xxx
# mount -t nfs xxxx:/daa12312312 /data01
