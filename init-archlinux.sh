pacman -S \
    vim tmux tree git htop man-db \
    nfs-utils smartmontools ranger \
    chrony dhcpcd dolphin ntfs-3g lsof \
    tig ncdu rsync btrfs-progs

pacman -S \
    sway swaybg swayidle swaylock foot dmenu gammastep \
    xorg-xwayland qt5-wayland qt6-wayland qt5ct \
    polkit pipewire-pulse pavucontrol \
    i3blocks i3status intel-gpu-tools \
    intel-media-driver mpv libva-utils \
    chromium firefox

pacman -S \
    adobe-source-han-sans-cn-fonts \
    adobe-source-han-serif-cn-fonts \
    ttf-ubuntu-mono-nerd \
    noto-fonts-cjk

pacman -S \
    brightnessctl \
    upower

pacman -S \
    qemu-full libvirt virt-manager \
    dnsmasq dmidecode ovmf remmina

pacman -S libreoffice-fresh gimp lollypop

# gammastep -O 4500K
# showmount -e 192.168.xxx
# mount -t nfs xxxx:/daa12312312 /data01
