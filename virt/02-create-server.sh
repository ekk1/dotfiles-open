qemu-system-x86_64 \
    -drive file=testvm-1.qcow2,if=virtio \
    -netdev user,id=netout,hostname=testvm-1,restrict=on,hostfwd=tcp:127.0.0.1:2222-:22 \
    -device virtio-net,netdev=netout \
    -netdev socket,id=netshare,listen=127.0.0.1:3333 \
    -device virtio-net,netdev=netshare \
    -device virtio-rng-pci \
    -m 2G -smp 2 \
    -name "testvm-1" \
    -boot d -vnc 127.0.0.1:10 \
    -monitor tcp:127.0.0.1:6001,server,nowait \
    -serial tcp:127.0.0.1:5001,server,nowait \
    -daemonize \
    -display none

# nc 127.0.0.1 5001
# ssh -R 9050 -p 2222 xxx@127.0.0.1

# Extra options
    # -enable-kvm
    # -netdev socket,id=netshare,listen=127.0.0.1:3333 \
    # -netdev socket,id=netshare,connect=127.0.0.1:3333 \
    # -monitor unix:/tmp/monitor.sock,server,nowait \
    # nc -U /tmp/monitor.sock

# VNC: 127.0.0.1:5901
# In VNC

# login as root
# ssh-keygen -A
# sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# systemctl restart ssh
# useradd -m -s /usr/bin/bash user
# passwd user
# passwd root

# ssh -R 9050 -p 2222 user@127.0.0.1
# su
# growpart /dev/vda 1
# resize2fs /dev/vda1

# echo "Acquire::https::proxy \"socks5h://127.0.0.1:9050\";" >> /etc/apt/apt.conf.d/90proxy

# sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/mirrors/debian.list
# sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/mirrors/debian-security.list

# echo "export PATH=$PATH:/sbin:/usr/sbin" >> /root/.bashrc

# apt install locales
# vim /etc/locale.gen
# locale-gen

# apt install privoxy
# listen-address   forward-socks5t

# apt install sysbench
# sysbench --threads=1 --time=15 --report-interval=3 cpu run
# sysbench --threads=4 --time=15 --report-interval=3 cpu run
