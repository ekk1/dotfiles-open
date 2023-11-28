#!/bin/bash
set -o nounset

base_dir="/srv/vms"
if [[ ! -z $1 ]]; then
    base_image=$1
else
    base_image=""
fi

if [[ ! -z $2 ]]; then
    disk_name="/dev/shm/virt"

disk_name="testvm-1.qcow2"

qemu-img create -f qcow2 -b ${base_image} -F qcow2 ${disk_name} 20G
chmod 600 ${disk_name}
