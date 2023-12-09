# Vim related
apt install vim-nox vim-youcompleteme \
    vim-ctrlp vim-airline \
    vim-airline-themes vim-addon-manager \
    vim-ale

# Terminal tools
apt install ncdu htop tmux netcat-openbsd \
    wget curl iptables tig powerline ranger \
    rsync cryptsetup ripgrep \
    ansible command-not-found elinks w3m

cat << EOF > /root/00-startup.sh
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
ExecStart=bash /root/00-startup.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable sa-pc-startup.service
