#!/bin/bash

if [[ ! -z $1 ]]; then
    disk_name="/dev/shm/virt/testvmw-1.qcow2"
else
    disk_name="/srv/vms/testvmw-1.qcow2"
fi

qemu-system-x86_64 \
    -enable-kvm \
    -m 2G -smp 2 \
    -drive file=${disk_name} \
    -cdrom /srv/vms/windows.iso \
    -netdev socket,id=netout,connect=127.0.0.1:3333 \
    -device e1000,netdev=netout \
    -usb -device usb-tablet \
    -name "testvmw-1" \
    -boot menu=on -vnc 127.0.0.1:11 \
    -monitor tcp:127.0.0.1:6002,server,nowait \
    -serial tcp:127.0.0.1:5002,server,nowait \
    -daemonize \
    -display none
