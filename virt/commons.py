"""common"""
import os

flavor_list = {
    "1c1g":     "-m 1G -smp 1",
    "8c16g":    "-m 16G -smp 8",
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
    while True:
        a = input("Select: ")
        try:
            aa = int(a)
        except ValueError:
            print("Failed to decode")
            continue
        if aa not in _mapping:
            print("Failed to select")
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
