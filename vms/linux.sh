qemu-system-x86_64 \
    -m 4G -smp 1 \
    -drive file=base.qcow2,if=virtio \
    -cdrom meta.iso \
    -netdev 'user,id=netout,hostname=testvm,restrict=on,hostfwd=tcp:127.0.0.1:2221-:22,guestfwd=tcp:10.0.2.100:8118-cmd:nc -q 0 127.0.0.1 9902' \
    -device virtio-net,netdev=netout \
    -device virtio-rng-pci \
    -name "testvm" \
    -boot d \
    -vnc 127.0.0.1:11 \
    -monitor tcp:127.0.0.1:6001,server,nowait \
    -serial tcp:127.0.0.1:5001,server,nowait \
    -sandbox on -display none \
    -enable-kvm -cpu host

# for testing with KMS, might need 3D accel
#
# -vga none \
# -display gtk,gl=on \
# -device virtio-vga-gl \
