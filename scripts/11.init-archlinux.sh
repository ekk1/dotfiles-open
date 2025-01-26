# Cli tools
echo "All answers should be y or skip"

read -p "Do you wish to install cli tools?" yn
if [[ $yn == "y" ]]; then
    pacman -S \
        vim tmux tree git htop man-db \
        nfs-utils smartmontools ranger \
        chrony dhcpcd ntfs-3g lsof \
        tig ncdu rsync btrfs-progs unrar \
        p7zip python openbsd-netcat \
        powerline tk wget \
        linux-firmware-qlogic \
        neofetch openssh helix zellij fish \
        imagemagick ghostscript
fi

read -p "Do you wish to install GUI?" yn
if [[ $yn == "y" ]]; then
    echo "Choose pipewire related options"
    echo "wireplumber  pipewire-jack  noto-fonts"
    pacman -S \
        sway swaybg swayidle swaylock foot dmenu gammastep \
        xorg-xwayland qt5-wayland qt6-wayland qt5ct \
        polkit pipewire-pulse pavucontrol \
        i3blocks i3status intel-gpu-tools \
        intel-media-driver mpv libva-utils \
        chromium firefox hyprland dolphin \
        sway-contrib
fi

read -p "Do you wish to install vulkan driver?" yn
if [[ $yn == "y" ]]; then
    pacman -S vulkan-intel vulkan-tools
fi

read -p "Do you wish to install fonts?" yn
if [[ $yn == "y" ]]; then
    pacman -S \
        adobe-source-han-sans-cn-fonts \
        adobe-source-han-serif-cn-fonts \
        ttf-ubuntu-mono-nerd ttf-ubuntu-font-family \
        noto-fonts-cjk \
        noto-fonts-emoji \
        powerline-fonts
fi

read -p "Do you wish to install laptop tools?" yn
if [[ $yn == "y" ]]; then
    pacman -S \
        brightnessctl \
        upower \
        iwd
fi

read -p "Do you wish to install kvm tools?" yn
if [[ $yn == "y" ]]; then
    pacman -S \
        qemu-full libvirt virt-manager \
        dnsmasq dmidecode ovmf \
        remmina freerdp libvncserver
fi

read -p "Do you wish to install extra GUI tools?" yn
if [[ $yn == "y" ]]; then
    pacman -S libreoffice-fresh gimp \
        lollypop gthumb grim \
        code yt-dlp \
        fcitx5-im fcitx5-chinese-addons
fi

read -p "Do you wish to apply common settings?" yn
if [[ $yn == "y" ]]; then
    echo "continue"
else
    echo "Skipped common setting"
    exit 0
fi

# startup script
echo "Writing startup scripts"
cat << EOF > /root/00-startup.sh
iptables -F
iptables -X
iptables -P INPUT DROP
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -P FORWARD DROP
EOF

echo "Writing startup service"
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

echo "Writing common scripts"

cat << EOF > /home/sa/00-night-colors.sh
gammastep -O 4500K
EOF

cat << EOF > /home/sa/01-snapshot.sh
grim
EOF

cat << EOF > /root/01-start-dhcp.sh
systemctl start dhcpcd
EOF

cat << EOF > /root/09-start-static.sh
ip a add 192.168.x.x/24 dev enpxxx
ip link set enpxx up
ip r add default via 192.168.x.1
EOF

cat << EOF > /root/04-start-wlan.sh
# systemctl start dhcpcd
systemctl start iwd
# iwctl
# device list
# station wlan0 scan
# station wlan0 get-networks
# station wlan0 connect xxxx
#
# /var/lib/iwd/spaceship.psk (for example)
# [Settings]
# AutoConnect=false
#
# /etc/iwd/main.conf
# [Scan]
# DisablePeriodicScan=true
#
# ip a add 192.168.x.x/24 dev wlan0
# ip link set wlan0 up
# ip r add default via 192.168.x.1
EOF

cat << EOF > /root/05-reconnect-wlan.sh
iwctl station wlan disconnect
iwctl station wlan connect xxxx
EOF

cat << EOF > /root/06-restart-network-service.sh
systemctl restart systemd-resolved
sleep 2
systemctl restart chronyd
EOF

cat << EOF > /root/02-list-nfs-mount.sh
showmount -e 192.168.xxx
EOF

cat << EOF > /root/03-mount-nfs.sh
mkdir -p /data01 /data02 /data03
mount -t nfs 192.168.xxx:/path /data01
mount -t nfs 192.168.xxx:/path /data02
mount -t nfs 192.168.xxx:/path /data03
EOF

cat << EOF > /etc/sysctl.d/40-ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
EOF

echo "Run fcitx5-configtool, add pinyin"
echo "run fcitx5 when needed"
echo "Copy config_dir/ to ~/.config"
