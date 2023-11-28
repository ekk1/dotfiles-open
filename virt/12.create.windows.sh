#!/bin/bash

if [[ ! -z $1 ]]; then
    disk_name="/dev/shm/virt/testvm-1.qcow2"
else
    disk_name="/srv/vms/testvm-1.qcow2"
fi

qemu-system-x86_64 \
    -enable-kvm \
    -m 2G -smp 2 \
    -drive file=${disk_name} \
    -cdrom /srv/vms/windows.iso \
    -netdev user,id=netout,hostname=testvm-1,restrict=on,hostfwd=tcp:127.0.0.1:3389-:3389 \
    -device e1000,netdev=netout \
    -usb -device usb-tablet \
    -name "testvmw-1" \
    -boot menu=on -vnc 127.0.0.1:10 \
    -monitor tcp:127.0.0.1:6001,server,nowait \
    -serial tcp:127.0.0.1:5001,server,nowait \
    -daemonize \
    -display none
