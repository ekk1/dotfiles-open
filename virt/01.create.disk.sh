#!/bin/bash
base_dir="/srv/vms"
if [[ ! -z $1 ]]; then
    base_image_flag="-b ${1} -F qcow2"
else
    base_image_flag=""
fi

if [[ ! -z $2 ]]; then
    mkdir -p /dev/shm/virt
    chown $USER:$USER /dev/shm/virt
    chmod 700 /dev/shm/virt
    disk_name="/dev/shm/virt/testvm-1.qcow2"
else
    disk_name="/srv/vms/testvm-1.qcow2"
fi

qemu-img create -f qcow2 ${base_image_flag} ${disk_name} 20G
chmod 600 ${disk_name}
