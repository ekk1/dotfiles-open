#!/bin/bash

ram_virt_dir="/dev/shm/virt"
disk_name="testvm-1.img"

echo "Creating vm"

qemu_iso_flag=""
qemu_kvm=""
qemu_nic_type=""
qemu_disk_if=""
qemu_virtio_rng=""
qemu_target_disk=""
qemu_size=""
qemu_machine=""

query_iso=$(ls *.iso)
if [[ $? == 0 ]]; then
    select iii in no $query_iso
    do
        if [[ $iii == "no" ]]; then
            echo "Skipping ISO"
            break
        fi
        if [[ ! -z $iii ]]; then
            echo "Using ISO: $iii"
            qemu_iso_flag="-drive file=${iii},if=scsi,media=cdrom"
            break
        fi
    done
fi

echo "Choose kvm or not"
select ch in kvm pure-qemu
do
    case $ch in
        kvm)
            qemu_kvm="-enable-kvm"
            ;;
        pure-qemu)
            ;;
    esac
    break
done
echo "Starting qemu with ${qemu_kvm}"

echo "Select OS type"
select ch in linux windows
do
    case $ch in
        windows)
            qemu_nic_type="e1000"
            qemu_disk_if="scsi"
            qemu_machine="-machine pc-q35-8.1"
            break
            ;;
        linux)
            qemu_nic_type="virtio-net"
            qemu_virtio_rng="-device virtio-rng-pci"
            qemu_disk_if="virtio"
            break
            ;;
    esac
done
echo "Starting qemu with nic ${qemu_nic_type}"

select ch in file ram
do
    case $ch in
        file)
            qemu_target_disk=${disk_name}
            break
            ;;
        ram)
            qemu_target_disk="${ram_virt_dir}/${disk_name}"
            break
            ;;
    esac
done
echo "Using ${qemu_target_disk}"

select ch in 2C2G 8C8G 8C32G 16C48G;
do
    case $ch in
        2C2G)
            qemu_size="-m 2G -smp 2"
            break
            ;;
        8C8G)
            qemu_size="-m 8G -smp 8"
            break
            ;;
        8C32G)
            qemu_size="-m 32G -smp 8"
            break
            ;;
        16C48G)
            qemu_size="-m 48G -smp 16"
            break
            ;;
    esac
done
echo "Starting with ${qemu_size}"

qemu-system-x86_64 \
    ${qemu_kvm} \
    ${qemu_size} \
    ${qemu_iso_flag} \
    ${qemu_machine} \
    -drive file=${qemu_target_disk},if=${qemu_disk_if} \
    -netdev user,id=netout,hostname=testvm-1,restrict=on,hostfwd=tcp:127.0.0.1:2222-:22 \
    -device ${qemu_nic_type},netdev=netout \
    -netdev socket,id=netshare,listen=127.0.0.1:3333 \
    -device ${qemu_nic_type},netdev=netshare \
    ${qemu_virtio_rng} \
    -name "testvm-1" \
    -boot d -vnc 127.0.0.1:10 \
    -monitor tcp:127.0.0.1:6001,server,nowait \
    -serial tcp:127.0.0.1:5001,server,nowait \
    -daemonize \
    -display none
    # -rtc \

# Extra options
    # -enable-kvm \
    # -m 32G -smp 8 \
    # -netdev socket,id=netshare,listen=127.0.0.1:3333 \
    # -netdev socket,id=netshare,connect=127.0.0.1:3333 \
    # -device virtio-net,netdev=netshare \
    # -monitor unix:/tmp/monitor.sock,server,nowait \
    # nc -U /tmp/monitor.sock

