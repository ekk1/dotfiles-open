#!/bin/bash
echo "Acquire::https::proxy \"socks5h://127.0.0.1:9050\";" >> /etc/apt/apt.conf.d/90proxy
echo "Acquire::http::proxy \"socks5h://127.0.0.1:9050\";" >> /etc/apt/apt.conf.d/90proxy
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/mirrors/debian.list
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/mirrors/debian-security.list
# if using self hosted apt
#sed -i 's/deb.debian.org/192.168.x.x/g' /etc/apt/mirrors/debian.list
#sed -i 's/deb.debian.org/192.168.x.x/g' /etc/apt/mirrors/debian-security.list
#sed -i 's/https/http/g' /etc/apt/mirrors/debian.list
#sed -i 's/https/http/g' /etc/apt/mirrors/debian-security.list
sed -i 's/main/main contrib/'   /etc/apt/sources.list.d/debian.sources
sed -i 's/deb deb-src/deb/'     /etc/apt/sources.list.d/debian.sources
apt update

apt install -y locales
echo "en_HK.UTF-8 UTF-8" > /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

apt install -y vim htop ncdu tmux curl wget python3
apt install -y sysbench
apt upgrade -y

cat << EOF > 00.install.http.proxy.sh
apt install -y privoxy
echo "forward-socks5t / 127.0.0.1:9050 ." >> /etc/privoxy/config
echo "debug 13313" >> /etc/privoxy/config
systemctl restart privoxy
echo "RUN terminalProxyStart using user !!!"
EOF

cat << EOF > 01.install.dev.env.sh
apt install -y \
    vim-nox vim-airline vim-airline-themes \
    powerline vim-ctrlp vim-youcompleteme \
    vim-addon-manager vim-ale \
    python3-flask python3-rich python3-cryptography \
    pylint shellcheck
EOF

cat << EOF > 02.install.gui.env.sh
#!/bin/bash
sudo apt update
sudo apt install -y xfce4 xfce4-goodies
# sudo apt install -y novnc python3-websockify
# may need this
# sudo apt install -y dbus-x11
# websockify  --web=/usr/share/novnc/ 127.0.0.1:6801 127.0.0.1:5901


# sudo apt install -y tigervnc-standalone-server
# vncserver
# vncserver -kill :1

# mv ~/.vnc/xstartup ~/.vnc/xstartup.bak

# cat >~/.vnc/xstartup <<EOF
# # For Xfce4
# #!/bin/bash
# xrdb \$HOME/.Xresources
# startxfce4
# EOF

# sudo chmod +x ~/.vnc/xstartup
# vncserver -geometry 1280x720 -localhost
EOF

exit
