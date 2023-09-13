#!/bin/bash

ram_virt_dir="/dev/shm/virt"
base_image="debian-12-nocloud-amd64-20230910-1499.qcow2"
disk_name="testvm-1.qcow2"
raw_name="testvm-1.img"

echo "Creating $disk_name, possible with $base_image"
echo "Choose disk type"

select ch in base raw base-ram raw-ram
do
    case $ch in
        base)
            qemu-img create \
                -f qcow2 -b ${base_image} \
                -F qcow2 ${disk_name} 20G
            chmod 600 ${disk_name}
            ;;
        raw)
            qemu-img create \
                -f raw ${raw_name} 20G
            chmod 600 ${raw_name}
            ;;
        base-ram)
            mkdir -p ${ram_virt_dir}
            chmod 700 ${ram_virt_dir}
            qemu-img create \
                -f qcow2 -b "$(pwd)/${base_image}" \
                -F qcow2 "${ram_virt_dir}/${disk_name}" 10G
            chmod 600 "${ram_virt_dir}/${disk_name}"
            ;;
        raw-ram)
            mkdir -p ${ram_virt_dir}
            chmod 700 ${ram_virt_dir}
            qemu-img create \
                -f raw "${ram_virt_dir}/${raw_name}" 10G
            chmod 600 "${ram_virt_dir}/${raw_name}"
            ;;
        *)
            break
            ;;
    esac
done


