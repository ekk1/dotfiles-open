#!/bin/bash
set -o nounset

ram_virt_dir="/dev/shm/virt"
disk_name="testvm-1.qcow2"

rsync -avP ${ram_virt_dir}/${disk_name} ./${disk_name}
