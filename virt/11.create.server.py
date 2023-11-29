#!/bin/python3
"""create a qemu server"""
import argparse
import os
import subprocess

def run_cmd(cmd, env=None):
    """run cmd"""
    print("Running: ", cmd)
    _ss = subprocess.run(
        ['bash', '-c' , cmd],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        universal_newlines=True,
        env=env,
        check=False,
    )
    print(_ss.stdout)
    print(_ss.stderr)

pp = argparse.ArgumentParser()
pp.add_argument('-w', '--win', action="store_true", help="windows")
pp.add_argument('-r', '--ram', action="store_true", help="ram based")
pp.add_argument('-t', '--tpm', action="store_true", help="add tpm")
pp.add_argument('-k', '--kvm', action="store_true", help="enable kvm")
pp.add_argument('-x', '--large', action="store_true", help="larger vm")
pp.add_argument('-n', '--net', action="store_true", help="free network")
pp.add_argument('-c', '--client', action="store_true", help="client network")
pp.add_argument('-s', '--server', action="store_true", help="server network")
pp.add_argument('filename', nargs='?', help="back file to use")
aa = pp.parse_args()

if aa.win:
    VM_NAME = "testvmw-1"
    LISTEN_PORT = "2223"
    ACCESS_PORT = "3389"
    NIC_DRIVER = 'e1000'
    DISK_DRIVER = ''
    EXTRA_DISK = '-cdrom /srv/vms/windows.iso '
    BOOT_OPTION = "-boot menu=on "
    VNC_PORT = "11"
    MONITOR_PORT = "6002"
    SERIAL_PORT = "5002"
    EXTRA_DEVICE = "-usb -device usb-tablet -machine pc-q35-7.2 "
else:
    VM_NAME = 'testvm-1'
    LISTEN_PORT = "2222"
    ACCESS_PORT = "22"
    NIC_DRIVER = "virtio-net"
    DISK_DRIVER = ",if=virtio"
    EXTRA_DISK = "-drive driver=raw,file=seed.iso,if=virtio "
    BOOT_OPTION = "-boot d "
    VNC_PORT = "10"
    MONITOR_PORT = "6001"
    SERIAL_PORT = "5001"
    EXTRA_DEVICE = "-device virtio-rng-pci "

if aa.ram:
    DISK_NAME = f"/dev/shm/virt/{VM_NAME}.qcow2"
else:
    DISK_NAME = f"/srv/vms/{VM_NAME}.qcow2"

if not os.path.exists(DISK_NAME):
    if aa.ram:
        run_cmd("mkdir -p /dev/shm/virt")
        run_cmd("chown $USER:$USER /dev/shm/virt")
        run_cmd("chmod 700 /dev/shm/virt")
    base_image_flag = f"-b {aa.filename} -F qcow2" if aa.filename is not None else ""
    run_cmd(f"qemu-img create -f qcow2 {base_image_flag} {DISK_NAME} 20G")
    run_cmd(f"chmod 600 {DISK_NAME}")

USER_NIC = ""

if not aa.client:
    USER_NIC += f"-netdev user,id=netout,hostname={VM_NAME},"
    if not aa.net:
        USER_NIC += "restrict=on,"
    USER_NIC += f"hostfwd=tcp:127.0.0.1:{LISTEN_PORT}-:{ACCESS_PORT} "
    USER_NIC += f"-device {NIC_DRIVER},netdev=netout "
else:
    USER_NIC += "-netdev socket,id=netshare,connect=127.0.0.1:3333 "
    USER_NIC += f"-device {NIC_DRIVER},netdev=netshare "

if aa.server:
    USER_NIC += "-netdev socket,id=netshare,listen=127.0.0.1:3333 "
    USER_NIC += f"-device {NIC_DRIVER},netdev=netshare "

QEMU_BASE = "qemu-system-x86_64 "
if aa.kvm:
    QEMU_BASE += "-enable-kvm "

if aa.large:
    QEMU_BASE += "-m 8G -smp 8 "
else:
    QEMU_BASE += "-m 2G -smp 2 "

QEMU_BASE += f"-drive file={DISK_NAME}{DISK_DRIVER} "
QEMU_BASE += EXTRA_DISK
QEMU_BASE += USER_NIC
QEMU_BASE += EXTRA_DEVICE

QEMU_BASE += f"-name \"{VM_NAME}\" "

QEMU_BASE += BOOT_OPTION
QEMU_BASE += f"-vnc 127.0.0.1:{VNC_PORT} "
QEMU_BASE += f"-monitor tcp:127.0.0.1:{MONITOR_PORT},server,nowait "
QEMU_BASE += f"-serial tcp:127.0.0.1:{SERIAL_PORT},server,nowait "

QEMU_BASE += "-sandbox on "
# QEMU_BASE += "-sandbox on,obsolete=deny,elevateprivileges=deny"
# QEMU_BASE += ",spawn=deny,resourcecontrol=deny "
QEMU_BASE += "-daemonize -display none "

if aa.tpm:
    QEMU_BASE += "-cpu host"
    QEMU_BASE += "-bios /usr/share/ovmf/x64/OVMF.fd "
    QEMU_BASE += "-chardev socket,id=chrtpm,path=/tmp/swtpm-sock "
    QEMU_BASE += "-tpmdev emulator,id=tpm0,chardev=chrtpm "
    QEMU_BASE += "-device tpm-tis,tpmdev=tpm0 "

run_cmd(QEMU_BASE)
