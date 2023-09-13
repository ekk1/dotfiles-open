#!/bin/bash

ram_virt_dir="/dev/shm/virt"
base_image="debian-12-nocloud-amd64-20230910-1499.qcow2"
disk_name="testvm-1.qcow2"
raw_name="testvm-1.img"

echo "Deleting"
echo "Choose disk type"

select ch in list base raw base-ram raw-ram
do
    case $ch in
        list)
            ls testvm*
            ls ${ram_virt_dir}/testvm*
            ;;
        base)
            rm ${disk_name}
            ;;
        raw)
            rm ${raw_name}
            ;;
        base-ram)
            rm "${ram_virt_dir}/${disk_name}"
            ;;
        raw-ram)
            rm "${ram_virt_dir}/${raw_name}"
            ;;
        *)
            break
            ;;
    esac
done


