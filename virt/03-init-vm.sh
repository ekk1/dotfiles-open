# bash 22-conn

# login as root
ssh-keygen -A
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart ssh
useradd -m -s /usr/bin/bash user
passwd user
passwd root
echo "export PATH=\$PATH:/sbin:/usr/sbin" >> /root/.bashrc

bash 21-ssh
su
growpart /dev/vda 1
resize2fs /dev/vda1

echo "Acquire::https::proxy \"socks5h://127.0.0.1:9050\";" >> /etc/apt/apt.conf.d/90proxy
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/mirrors/debian.list
sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/mirrors/debian-security.list
sed -i 's/main/main contrib/'   /etc/apt/sources.list.d/debian.sources
sed -i 's/deb deb-src/deb/'     /etc/apt/sources.list.d/debian.sources
apt update

apt install locales
echo "en_HK.UTF-8 UTF-8" > /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

apt install privoxy
echo "forward-socks5t / 127.0.0.1:9050 ." >> /etc/privoxy/config
echo "debug 13313" >> /etc/privoxy/config
systemctl restart privoxy

apt install sysbench vim htop ncdu tmux git curl wget python3
apt install vim-nox vim-airline vim-airline-themes
apt install vim-ctrlp vim-youcompleteme vim-addon-manager
apt install vim-ale
apt install python3-flask python3-rich python3-cryptography

echo "alias terminalProxyStart='export https_proxy=http://127.0.0.1:8118; export all_proxy=http://127.0.0.1:8118'" >> /home/user/.bashrc
git clone https://github.com/ekk1/dotfiles-open.git
vam install youcompleteme
echo "/home/user/.vimrc" >> /home/user/.vim_jump_cache
cp dotfiles-open/tmux.conf .tmux.conf
cp dotfiles-open/make-vim-better/vimrc .vimrc

sysbench cpu run

