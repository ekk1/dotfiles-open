qemu-system-x86_64 \
    -drive file=testvm-1.qcow2,if=virtio \
    -netdev user,id=netout,hostname=testvm-1,restrict=on,hostfwd=tcp:127.0.0.1:2222-:22 \
    -device virtio-net,netdev=netout \
    -netdev socket,id=netshare,listen=127.0.0.1:3333 \
    -device virtio-net,netdev=netshare \
    -device virtio-rng-pci \
    -m 2G -smp 4 \
    -name "testvm-1" \
    -boot d -vnc 127.0.0.1:1 \
    -monitor tcp:127.0.0.1:6001,server,nowait \
    -daemonize \
    -display none

# qemu-system-x86_64 \
#     -drive file=testvm-1.qcow2,if=virtio \
#     -netdev user,id=netout,hostname=testvm-1,restrict=on,hostfwd=tcp:127.0.0.1:2222-:22 \
#     -device virtio-net,netdev=netout \
#     -netdev socket,id=netshare,connect=127.0.0.1:3333 \
#     -device virtio-net,netdev=netshare \
#     -device virtio-rng-pci \
#     -m 2G -smp 4 \
#     -name "testvm-1" \
#     -boot d -vnc 127.0.0.1:1 \
#     -monitor tcp:127.0.0.1:6001,server,nowait \
#     -daemonize \
#     -display none

    # -netdev socket,id=netshare,listen=127.0.0.1:3333 \
    # -netdev socket,id=netshare,connect=127.0.0.1:3333 \
    # -monitor unix:/tmp/monitor.sock,server,nowait \
    # nc -U /tmp/monitor.sock

# vim /etc/apt/apt.conf.d/90proxy
# Acquire::https::proxy "socks5h://server:port";
