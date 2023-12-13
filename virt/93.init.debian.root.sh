#!/bin/bash
for i in "$@"
do
case $i in
    -a=*|--apt=*)
    MIRROR_HOST="${i#*=}"
    ;;
    -i=*|--interface=*)
    INNER_NETWORK="${i#*=}"
    ;;
    -n=*|--http=*)
    USE_HTTP="YES"
    ;;
    -p=*|--proxy=*)
    USER_PROXY="YES"
    ;;
    *)
    ;;
esac
done

if [[ "$USER_PROXY"x == "YESx" ]]; then
    echo "Acquire::https::proxy \"socks5h://127.0.0.1:9050\";" > /etc/apt/apt.conf.d/90proxy
    echo "Acquire::http::proxy \"socks5h://127.0.0.1:9050\";" >> /etc/apt/apt.conf.d/90proxy
fi

sed -i "s/deb.debian.org/${MIRROR_HOST}/g" /etc/apt/mirrors/debian.list
sed -i "s/deb.debian.org/${MIRROR_HOST}/g" /etc/apt/mirrors/debian-security.list
# if using self hosted apt
if [[ "$USE_HTTP"x == "YESx" ]]; then
    echo "Using http repo"
    sed -i 's/https/http/g' /etc/apt/mirrors/debian.list
    sed -i 's/https/http/g' /etc/apt/mirrors/debian-security.list
fi
cat << EOF > /etc/apt/sources.list.d/debian.sources
Types: deb
URIs: mirror+file:///etc/apt/mirrors/debian.list
Suites: bookworm bookworm-updates bookworm-backports
Components: main contrib

Types: deb
URIs: mirror+file:///etc/apt/mirrors/debian-security.list
Suites: bookworm-security
Components: main contrib
EOF
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

touch /root/00-startup.sh

if [[ ! -z $INNER_NETWORK ]]; then
cat << EOF > /root/00-startup.sh
ip a add $INNER_NETWORK/24 dev ens4
ip link set ens4 up
EOF
bash /root/00-startup.sh
fi

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
