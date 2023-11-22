#!/bin/bash
set -o nounset

base_image=$1
disk_name="testvm-1.qcow2"

qemu-img create -f qcow2 -b ${base_image} -F qcow2 ${disk_name} 20G
chmod 600 ${disk_name}
