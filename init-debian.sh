# Vim related
apt install vim vim-nox vim-youcompleteme vim-ctrlp vim-airline vim-airline-themes vim-addon-manager vim-ale vim-python-jedi

# Sway
apt install sway swaybg swayidle swaylock sway-backgrounds foot dmenu wofi i3status i3blocks

# Fonts
apt install fonts-noto-cjk fonts-noto-mono fonts-noto-color-emoji fonts-noto-cjk-extra fonts-font-awesome fonts-powerline fonts-ubuntu-console

# Kernel building
apt install pahole
apt install build-essential binutils-dev libncurses5-dev libssl-dev ccache bison flex libelf-dev
apt install bc debhelper rsync
for i in ~/linux-surface/patches/[VERSION]/*.patch; do patch -p1 < $i; done
./scripts/kconfig/merge_config.sh <base-config> ~/linux-surface/configs/surface-5.10.confi
make menuconfig
make olddefconfig

make -j `getconf _NPROCESSORS_ONLN` bindeb-pkg LOCALVERSION=-linux-surface
dpkg -i linux-headers-[VERSION].deb linux-image-[VERSION].deb linux-libc-dev-[VERSION].deb

# Quick firewall
cat << EOF > /home/xxxx/00-startup.sh
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
ExecStart=bash /home/xxxx/00-startup.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable sa-pc-startup.service

# GPU Check
apt install mesa-utils inxi

inxi -G
glxinfo
switcheroolctl list

