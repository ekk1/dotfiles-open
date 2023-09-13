#!/bin/bash

ram_virt_dir="/dev/shm/virt"
base_image="debian-12-nocloud-amd64-20230910-1499.qcow2"
disk_name="testvm-1.img"

echo "Deleting"
echo "Choose disk type"

select ch in list file ram
do
    case $ch in
        list)
            ls -al | grep img
            ls -al ${ram_virt_dir}/
            ;;
        file)
            rm ${disk_name}
            ;;
        ram)
            rm ${ram_virt_dir}/${disk_name}
            ;;
    esac
    break
done


