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

# Extra options
    # -enable-kvm
    # -netdev socket,id=netshare,listen=127.0.0.1:3333 \
    # -netdev socket,id=netshare,connect=127.0.0.1:3333 \
    # -device virtio-net,netdev=netshare \
    # -monitor unix:/tmp/monitor.sock,server,nowait \
    # -m 32G -smp 8 \
    # nc -U /tmp/monitor.sock

