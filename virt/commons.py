"""common"""
import os
import utils

flavor_list = {
    "1c1g":     "-m 1G -smp 1 ",
    "8c16g":    "-m 16G -smp 8 ",
}

def create_vm_disk(
        backing_file="",
        ram_based=False,
        name="testvm-1.disk",
        raw_disk=False
    ):
    """command for generate vm disk"""
    cmd = "qemu-img create "
    if raw_disk:
        cmd += "-f raw "
    else:
        cmd += "-f qcow2 "
    if backing_file != "":
        cmd += f"-F qcow2 -b {backing_file} "
    if ram_based:
        os.mkdir("/dev/shm/virt", mode=0o700)
        cmd += "/dev/shm/virt/"
    cmd += name
    return cmd

def select_item(input_list):
    """common select menu"""
    _index = 0
    _mapping = {}
    for item in input_list:
        _mapping[_index] = item
        print(f"[{_index}] {item}")
        _index += 1
    while True:
        a = input("Select: ")
        try:
            aa = int(a)
        except ValueError:
            utils.log_print("Failed to decode", "ERROR")
            continue
        if aa not in _mapping:
            utils.log_print("Failed to select", "ERROR")
            continue
        return _mapping[aa]

def list_file(path, keyword):
    """list files by keyword"""
    filtered_list = []
    files = os.listdir(path)
    for _f in files:
        if keyword in _f:
            filtered_list.append(_f)
    return filtered_list

def create_vm(
        _guest_os="linux",
        _guest_name="testvm",
        _guest_flavor="1c1g",
        _guest_disk="testvm-1.disk",
        _guest_cdrom="",
        _guest_use_kvm=False,
    ):
    """command for create a vm"""
    _nic_driver = "virtio-net" if _guest_os == "linux" else "e1000"
    _nic_port   = "22" if _guest_os == "linux" else "3389"
    _disk_driver = "virtio-blk" if _guest_os == "linux" else "ide-hd"
    cmd = "qemu-system-x86_64 "
    if _guest_use_kvm:
        cmd += "-enable-kvm"
    if _guest_flavor not in flavor_list:
        utils.log_print("flavor not exists")
        return ""
    cmd += flavor_list[_guest_flavor]
    cmd += f"-blockdev driver=file,node-name=disk1,filename={_guest_disk} "
    cmd += "-device {_disk_driver},drive=disk1 "
    if _guest_cdrom != "":
        cmd += f"-blockdev driver=file,node-name=disk2,filename={_guest_disk} "
        if _guest_os == "linux":
            cmd += "-device virtio-scsi,id=scsi0 "
            cmd += "-device scsi-cd,drive=disk2,bus=scsi0.0 "
        else:
            cmd += "-device ide-cd,drive=disk2 "
    cmd += "-netdev user,id=netout,hostname=testvm-1"
    cmd += f",restrict=on,hostfwd=tcp:127.0.0.1:2222-:{_nic_port} "
    cmd += f"-device {_nic_driver},netdev=netout "
    cmd += "-netdev socket,id=netshare,listen=127.0.0.1:3333 "
    cmd += f"-device {_nic_driver},netdev=netshare "
    if _guest_os == "windows":
        cmd += "-machine pc-q35-7.2 -device usb-tablet -rtc base=localtime,driftfix=slew "
    if _guest_os == "linux":
        cmd += "-device virtio-rng-pci "
    cmd += f"-name {_guest_name} "
    cmd += "-boot d -vnc 127.0.0.1:10 "
    cmd += "-monitor tcp:127.0.0.1:6001,server,nowait "
    cmd += "-serial tcp:127.0.0.1:5001,server,nowait "
    cmd += "-daemonize -display none"
    return cmd
