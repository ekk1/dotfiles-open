#!/bin/bash
mkdir -p /dev/shm/virt
chmod 700 /dev/shm/virt
qemu-img create -f qcow2 -b "$(pwd)/debian-12-nocloud-amd64-20230910-1499.qcow2" -F qcow2 /dev/shm/virt/testvm-1.qcow2 10G
chmod 600 /dev/shm/virt/testvm-1.qcow2
