# Vim related
apt install vim-nox vim-ctrlp vim-ale \
    vim-airline vim-airline-themes

# Terminal tools
apt install ncdu htop tmux netcat-openbsd \
    wget curl iptables tig powerline ranger \
    rsync cryptsetup ripgrep tree \
    command-not-found elinks w3m \
    tcpdump strace neofetch mtr-tiny fzf dstat

# Coding related
apt install python3-httpbin python3-livereload fswatch

cat << EOF > /root/00-startup.sh
iptables -F
iptables -X
iptables -P INPUT DROP
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -P FORWARD DROP
EOF

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
