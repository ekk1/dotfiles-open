import subprocess

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
    print(cmd)
    return cmd

def select_item(input_list):
    pass

def list_file(path, keyword):
    pass

def create_vm(
        os="linux",
        name="testvm",
        flavor="1c1g",
        disk="testvm-1.disk",
        cdrom="",
        kvm=False,
    ):
    pass
