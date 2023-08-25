#!/bin/bash

set -o errexit

modprobe nbd max_part=8
qemu-nbd --connect=/dev/nbd0 $1
fdisk /dev/nbd0 -l
mkdir -p /mnt/rescue
mount /dev/nbd0p1 /mnt/rescue/

echo "export PATH=\$PATH:/usr/sbin:/sbin" >> /mnt/rescue/root/.bashrc

cat >/mnt/rescue/root/01-locales.txt <<EOF
en_HK.UTF-8 UTF-8
en_US.UTF-8 UTF-8
ja_JP.UTF-8 UTF-8
ko_KR.UTF-8 UTF-8
zh_CN GB2312
zh_CN.GB18030 GB18030
zh_CN.GBK GBK
zh_CN.UTF-8 UTF-8
zh_TW BIG5
EOF

cat >/mnt/rescue/root/99-startup.sh <<EOF
if [[ ! -f /root/.INIT_FLAG_DO_NOT_DELETE ]]; then
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    ssh-keygen -A
    systemctl restart ssh
    useradd -m -s /usr/bin/bash user
    echo "user:123" > /root/xx_passwd
    chpasswd </root/xx_passwd
    rm /root/xx_passwd
    touch /root/.INIT_FLAG_DO_NOT_DELETE
    date >> /root/.INIT_FLAG_TIME
else
    echo "Already init"
fi
EOF

cat >/mnt/rescue/etc/systemd/system/sa-pc-startup.service <<EOF
[Unit]
Description=Startup scripts

[Service]
Type=oneshot
ExecStart=bash /root/99-startup.sh

[Install]
WantedBy=multi-user.target
EOF

ln -s /etc/systemd/system/sa-pc-startup.service /mnt/rescue/etc/systemd/system/multi-user.target.wants/sa-pc-startup.service

cat >/mnt/rescue/root/00-init-vm.sh <<EOF
echo "Resizing disk"
growpart /dev/vda 1
resize2fs /dev/vda1

echo "Preparing apt env"
echo "Acquire::https::proxy \"socks5h://127.0.0.1:9050\";" >> /etc/apt/apt.conf.d/90proxy
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/mirrors/debian.list
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/mirrors/debian-security.list
sed -i 's/main/main contrib/'   /etc/apt/sources.list.d/debian.sources
sed -i 's/deb deb-src/deb/'     /etc/apt/sources.list.d/debian.sources

echo "Installing locale"
apt update
apt install -y locales
cp /root/01-locales.txt /etc/locale.gen
locale-gen

echo "Installing proxy"
apt install -y privoxy
echo "forward-socks5t   /               127.0.0.1:9050 ." >> /etc/privoxy/config
echo "debug 13313" >> /etc/privoxy/config
systemctl restart privoxy

echo "Installing basic env"
apt install -y \
    sysbench \
    vim htop ncdu \
    tmux git curl \
    wget vim-nox \
    vim-airline vim-airline-themes \
    vim-ctrlp \
    vim-youcompleteme vim-addon-manager

echo "alias terminalProxyStart='export https_proxy=http://127.0.0.1:8118; export all_proxy=http://127.0.0.1:8118'" >> /home/user/.bashrc
echo "git clone https://github.com/ekk1/dotfiles-open.git" >> /home/user/00-init-vm.sh
echo "vam install youcompleteme" >> /home/user/00-init-vm.sh
echo "/home/user/.vimrc" >> /home/user/.vim_jump_cache
echo "cp dotfiles-open/tmux.conf .tmux.conf" >> /home/user/00-init-vm.sh
echo "cp dotfiles-open/make-vim-better/vimrc .vimrc" >> /home/user/00-init-vm.sh
EOF

umount /mnt/rescue/
qemu-nbd --disconnect /dev/nbd0
