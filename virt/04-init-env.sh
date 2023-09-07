growpart /dev/vda 1
resize2fs /dev/vda1

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

apt install -y privoxy
echo "forward-socks5t / 127.0.0.1:9050 ." >> /etc/privoxy/config
echo "debug 13313" >> /etc/privoxy/config
systemctl restart privoxy

apt install -y sysbench vim htop ncdu tmux git curl wget python3
echo "alias terminalProxyStart='export https_proxy=http://127.0.0.1:8118; export all_proxy=http://127.0.0.1:8118'" >> /home/user/.bashrc

echo "RUN terminalProxyStart !!!"
exit
