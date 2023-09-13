#!/bin/bash
qemu-system-x86_64 \
    -enable-kvm \
    -m 8G -smp 8 \
    -cdrom archlinux-2023.09.01-x86_64.iso \
    -drive file=testvm-1.img,if=virtio,format=raw \
    -netdev user,id=netout,hostname=testvm-1,hostfwd=tcp:127.0.0.1:2222-:22 \
    -device virtio-net,netdev=netout \
    -netdev socket,id=netshare,listen=127.0.0.1:3333 \
    -device virtio-net,netdev=netshare \
    -device virtio-rng-pci \
    -vga virtio \
    -name "testvm-1" \
    -boot d -vnc 127.0.0.1:10 \
    -monitor tcp:127.0.0.1:6001,server,nowait \
    -serial tcp:127.0.0.1:5001,server,nowait \
    -daemonize \
    -display none
    # -rtc \

    # -vga qxl \
