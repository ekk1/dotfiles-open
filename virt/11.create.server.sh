#!/bin/bash

if [[ ! -z $1 ]]; then
    disk_name="/dev/shm/virt/testvm-1.qcow2"
else
    disk_name="/srv/vms/testvm-1.qcow2"
fi

qemu-system-x86_64 \
    -enable-kvm \
    -m 2G -smp 2 \
    -drive file=${disk_name},if=virtio \
    -drive driver=raw,file=seed.iso,if=virtio \
    -netdev user,id=netout,hostname=testvm-1,restrict=on,hostfwd=tcp:127.0.0.1:2222-:22 \
    -device virtio-net,netdev=netout \
    -netdev socket,id=netshare,listen=127.0.0.1:3333 \
    -device virtio-net,netdev=netshare \
    -device virtio-rng-pci \
    -name "testvm-1" \
    -boot d -vnc 127.0.0.1:10 \
    -monitor tcp:127.0.0.1:6001,server,nowait \
    -serial tcp:127.0.0.1:5001,server,nowait \
    -daemonize \
    -display none
