#!/bin/bash

ram_virt_dir="/dev/shm/virt"
disk_name="testvm-1.qcow2"
raw_name="testvm-1.img"

iso_name="${1}"

echo "Creating vm"
echo "Choose kvm or not"

qemu_kvm=""
qemu_target_disk=""
qemu_size=""
qemu_iso_flag=""
qemu_nic_type=""
qemu_virtio_rng=""
qemu_disk_if=""


select ch in kvm pure-qemu
do
    case $ch in
        kvm)
            qemu_kvm="-enable-kvm"
            break
            ;;
        pure-qemu)
            break
            ;;
    esac
done
echo "Starting qemu with ${qemu_kvm}"

echo "Select OS type"
select ch in windows linux
do
    case $ch in
        windows)
            qemu_nic_type="e1000"
            if [[ ! -z iso_name ]]; then
                qemu_iso_flag="-drive file=${iso_name},if=scsi,media=cdrom"
            fi
            qemu_disk_if="scsi"
            break
            ;;
        linux)
            qemu_nic_type="virtio-net"
            qemu_virtio_rng="-device virtio-rng-pci"
            if [[ ! -z iso_name ]]; then
                qemu_iso_flag="-drive file=${iso_name},if=scsi,media=cdrom"
            fi
            qemu_disk_if="virtio"
            break
            ;;
    esac
done
echo "Starting qemu with nic ${qemu_nic_type}"

select ch in base raw base-ram raw-ram
do
    case $ch in
        base)
            qemu_target_disk=${disk_name}
            break
            ;;
        raw)
            qemu_target_disk=${raw_name}
            break
            ;;
        base-ram)
            qemu_target_disk="${ram_virt_dir}/${disk_name}"
            break
            ;;
        raw-ram)
            qemu_target_disk="${ram_virt_dir}/${raw_name}"
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

#qemu-system-x86_64 \
#    ${qemu_kvm} \
#    ${qemu_size} \
#    ${qemu_iso_flag} \
#    -drive file=${qemu_target_disk},if=${qemu_disk_if} \
#    -netdev user,id=netout,hostname=testvm-1,restrict=on,hostfwd=tcp:127.0.0.1:2222-:22 \
#    -device ${qemu_nic_type},netdev=netout \
#    -netdev socket,id=netshare,listen=127.0.0.1:3333 \
#    -device ${qemu_nic_type},netdev=netshare \
#    ${qemu_virtio_rng} \
#    -name "testvm-1" \
#    -boot d -vnc 127.0.0.1:10 \
#    -monitor tcp:127.0.0.1:6001,server,nowait \
#    -serial tcp:127.0.0.1:5001,server,nowait \
#    -daemonize \
#    -display none
    # -rtc \

# Extra options
    # -enable-kvm \
    # -m 32G -smp 8 \
    # -netdev socket,id=netshare,listen=127.0.0.1:3333 \
    # -netdev socket,id=netshare,connect=127.0.0.1:3333 \
    # -device virtio-net,netdev=netshare \
    # -monitor unix:/tmp/monitor.sock,server,nowait \
    # nc -U /tmp/monitor.sock

