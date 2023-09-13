#!/bin/bash
mkdir -p /dev/shm/virt
chmod 700 /dev/shm/virt
qemu-img create -f raw /dev/shm/virt/testvm-1.img 10G
chmod 600 /dev/shm/virt/testvm-1.img
