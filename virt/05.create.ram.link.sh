#!/bin/bash
set -o nounset
set -o errexit

ram_virt_dir="/dev/shm/virt"
base_dir="/srv/vms"
base_image=$1
disk_name="testvm-1.qcow2"

mkdir -p ${ram_virt_dir}
chmod 700 ${ram_virt_dir}
rsync -avP ${base_image} ${base_dir}/${base_image}
ln -sf ${base_dir}/${base_image} ${ram_virt_dir}
qemu-img create -f qcow2 -b ${base_image} -F qcow2 ${ram_virt_dir}/${disk_name} 20G
chmod 600 ${ram_virt_dir}/${disk_name}
