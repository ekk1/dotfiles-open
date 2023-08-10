qemu-system-x86_64 \
    -drive file=test.qcow2,if=virtio \
    -netdev user,id=netout,hostname=TestVM-2,hostfwd=tcp:127.0.0.1:1113-:22 \
    -device virtio-net,netdev=netout \
    -netdev socket,id=netshare,connect=:1234 \
    -device virtio-net,netdev=netshare \
    -device virtio-rng-pci \
    -m 2G -smp 4 \
    -name "TestVM-2" \
    -boot d -vnc 127.0.0.1:2 \
    -monitor stdio \
    -display none

