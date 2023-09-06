# bash 22-conn

# login as root
ssh-keygen -A
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart ssh
useradd -m -s /usr/bin/bash user
passwd user
passwd root
echo "export PATH=\$PATH:/sbin:/usr/sbin" >> /root/.bashrc
exit
scp -P 2222 04-init-env.sh 05-extras.sh 06-user-extras.sh 07-vnc-extra.sh user@127.0.0.1:
