#!/bin/python3
"""create a qemu server"""
import argparse
import os
import subprocess
from pathlib import Path

def run_cmd(cmd, env=None, dry_run=False):
    """run cmd"""
    print("Running: ", cmd)
    if not dry_run:
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
pp.add_argument('-w', '--win',      action="store_true", help="windows")
pp.add_argument('-r', '--ram',      action="store_true", help="ram based")
pp.add_argument('-t', '--tpm',      action="store_true", help="add tpm")
pp.add_argument('-k', '--kvm',      action="store_true", help="enable kvm")
pp.add_argument('-x', '--large',    action="store_true", help="larger vm")
pp.add_argument('-n', '--net',      action="store_true", help="free network")
pp.add_argument('-d', '--dry',      action="store_true", help="show commands but not exec")
# pp.add_argument('-c', '--client',   action="store_true", help="client network")
# pp.add_argument('-s', '--server',   action="store_true", help="server network")
pp.add_argument('-m', '--multi',    type=int, help="multiple")
pp.add_argument('-a', '--apt',      type=str, help="apt mirror to use", default="https://mirrors.ustc.edu.cn")
pp.add_argument('filename', nargs='?', help="back file to use")
aa = pp.parse_args()

_multi_qemu = 1
if aa.multi is not None:
    _multi_qemu = aa.multi

for _vm_no in range(0, _multi_qemu):
    if aa.win:
        VM_NAME = "testvmw-" + str(_vm_no)
        LISTEN_PORT = str(2231 + _vm_no)
        ACCESS_PORT = "3389"
        NIC_DRIVER = 'e1000'
        DISK_DRIVER = ''
        EXTRA_DISK = '-cdrom /srv/vms/windows.iso '
        BOOT_OPTION = "-boot menu=on "
        VNC_PORT = str(21 + _vm_no)
        MONITOR_PORT = str(6011 + _vm_no)
        SERIAL_PORT = str(5011 + _vm_no)
        EXTRA_DEVICE = "-usb -device usb-tablet -machine pc-q35-7.2 "
    else:
        VM_NAME = 'testvm-' + str(_vm_no)
        LISTEN_PORT = str(2221 + _vm_no)
        ACCESS_PORT = "22"
        NIC_DRIVER = "virtio-net"
        DISK_DRIVER = ",if=virtio"
        EXTRA_DISK = f"-drive driver=raw,file=seed{_vm_no}.iso,if=virtio,readonly=on "
        BOOT_OPTION = "-boot d "
        VNC_PORT = str(11 + _vm_no)
        MONITOR_PORT = str(6001 + _vm_no)
        SERIAL_PORT = str(5001 + _vm_no)
        EXTRA_DEVICE = "-device virtio-rng-pci "

    if aa.ram:
        DISK_NAME = f"/dev/shm/virt/{VM_NAME}.qcow2"
    else:
        DISK_NAME = f"/srv/vms/{VM_NAME}.qcow2"

    if not os.path.exists(DISK_NAME):
        if aa.ram:
            run_cmd("mkdir -p /dev/shm/virt", dry_run=aa.dry)
            run_cmd("chown $USER:$USER /dev/shm/virt", dry_run=aa.dry)
            run_cmd("chmod 700 /dev/shm/virt", dry_run=aa.dry)
        base_image_flag = f"-b {aa.filename} -F qcow2" if aa.filename is not None else ""
        run_cmd(f"qemu-img create -f qcow2 {base_image_flag} {DISK_NAME} 20G", dry_run=aa.dry)
        run_cmd(f"chmod 600 {DISK_NAME}", dry_run=aa.dry)

    if not aa.win:
        if not os.path.exists('vm_key'):
            run_cmd("ssh-keygen -t ed25519 -f vm_key -N \"\"", dry_run=aa.dry)
        key_data = Path('vm_key.pub').read_text(encoding="utf8").rstrip()
        run_cmd(f'sed "s|__SSH_PUB_KEY__|{key_data}|" user-data-template > user-data', dry_run=aa.dry)
        cc_prefix = "  - \"echo '"
        startup_suffix = "' >> /root/00-startup.sh\"\n"
        service_suffix = "' >> /etc/systemd/system/sa-pc-startup.service\"\n"
        apt_suffix = "' >> /etc/apt/sources.list.d/debian.sources\"\n"
        apt_first_suffix = "' > /etc/apt/sources.list.d/debian.sources\"\n"
        service_first_suffix = "' > /etc/systemd/system/sa-pc-startup.service\"\n"
        locale_suffix = "' >> /etc/locale.gen\"\n"
        router_template = "\nruncmd:\n  - \"echo 'en_HK.UTF-8 UTF-8' > /etc/locale.gen\"\n"
        router_template += cc_prefix + "en_US.UTF-8 UTF-8" + locale_suffix
        router_template += cc_prefix + "zh_CN.UTF-8 UTF-8" + locale_suffix
        router_template += cc_prefix + "ja_JP.UTF-8 UTF-8" + locale_suffix
        router_template += "  - \"locale-gen\"\n"
        router_template += "  - \"echo -n '' > /root/00-startup.sh\"\n"
        router_template += cc_prefix + "[Unit]" + service_first_suffix
        router_template += cc_prefix + "Description=Init system boot" + service_suffix
        router_template += cc_prefix + "[Service]" + service_suffix
        router_template += cc_prefix + "Type=oneshot" + service_suffix
        router_template += cc_prefix + "ExecStart=bash /root/00-startup.sh" + service_suffix
        router_template += cc_prefix + "[Install]" + service_suffix
        router_template += cc_prefix + "WantedBy=multi-user.target" + service_suffix
        router_template += "  - systemctl daemon-reload\n"
        router_template += "  - systemctl enable sa-pc-startup.service\n"
        router_template += cc_prefix + "Types: deb" + apt_first_suffix
        router_template += cc_prefix + "URIs: mirror+file:///etc/apt/mirrors/debian.list" + apt_suffix
        router_template += cc_prefix + "Suites: bookworm bookworm-updates bookworm-backports" + apt_suffix
        router_template += cc_prefix + "Components: main contrib" + apt_suffix
        router_template += cc_prefix + "" + apt_suffix
        router_template += cc_prefix + "Types: deb" + apt_suffix
        router_template += cc_prefix + "URIs: mirror+file:///etc/apt/mirrors/debian-security.list" + apt_suffix
        router_template += cc_prefix + "Suites: bookworm-security" + apt_suffix
        router_template += cc_prefix + "Components: main contrib" + apt_suffix
        router_template += cc_prefix + aa.apt + "/debian" + "' > /etc/apt/mirrors/debian.list\"\n"
        router_template += cc_prefix + aa.apt + "/debian-security" + "' > /etc/apt/mirrors/debian-security.list\"\n"
        if _vm_no == 0:
            if _multi_qemu > 1:
                router_template += cc_prefix + "sysctl -w net.ipv4.ip_forward=1" + startup_suffix
                router_template += cc_prefix + "ip a add 192.168.199.11 dev ens4" + startup_suffix
                for _link_vms in range(0, _multi_qemu - 1):
                    router_template += cc_prefix + f"ip link set ens{4 + _link_vms} up" + startup_suffix
                    router_template += cc_prefix + f"ip r add 192.168.199.{12 + _link_vms} dev ens{4 + _link_vms}" + startup_suffix
        else:
            router_template += cc_prefix + f"ip a add 192.168.199.{11 + _vm_no} dev ens3" + startup_suffix
            router_template += cc_prefix + "ip link set ens3 up" + startup_suffix
            router_template += cc_prefix + "ip r add 192.168.199.11 dev ens3" + startup_suffix
            router_template += cc_prefix + "ip r add default via 192.168.199.11" + startup_suffix
            router_template += cc_prefix + "echo root:123 | chpasswd" + startup_suffix
        router_template += "  - bash /root/00-startup.sh\n"
        with open('user-data', 'a', encoding='utf8') as f:
            f.write(router_template)
        run_cmd(f"genisoimage -output seed{_vm_no}.iso -volid cidata -joliet -rock user-data meta-data", dry_run=aa.dry)
        run_cmd(f"cp user-data user-data{_vm_no}", dry_run=aa.dry)

    USER_NIC = ""

    if _vm_no == 0:
        USER_NIC += f"-netdev user,id=netout,hostname={VM_NAME},"
        if not aa.net:
            USER_NIC += "restrict=on,"
        USER_NIC += f"hostfwd=tcp:127.0.0.1:{LISTEN_PORT}-:{ACCESS_PORT} "
        USER_NIC += f"-device {NIC_DRIVER},netdev=netout "
        for _ppp_no in range(0, _multi_qemu - 1):
            USER_NIC += f"-netdev socket,id=netshare{1 + _ppp_no},listen=127.0.0.1:{3333 + _ppp_no} "
            USER_NIC += f"-device {NIC_DRIVER},netdev=netshare{1 + _ppp_no},mac=52:54:00:12:34:{11 + _ppp_no:02x} "
    else:
        USER_NIC += f"-netdev socket,id=netshare,connect=127.0.0.1:{3333 + _vm_no - 1} "
        USER_NIC += f"-device {NIC_DRIVER},netdev=netshare,mac=52:54:00:12:35:{11 + _vm_no - 1:02x} "

    QEMU_BASE = "qemu-system-x86_64 "
    if aa.kvm:
        QEMU_BASE += "-enable-kvm "

    if _multi_qemu > 1 and _vm_no == 0:
        QEMU_BASE += "-m 2G -smp 2 "
    else:
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
    QEMU_BASE += "-cpu host "

    if aa.tpm:
        QEMU_BASE += "-bios /usr/share/ovmf/x64/OVMF.fd "
        QEMU_BASE += "-chardev socket,id=chrtpm,path=/tmp/swtpm-sock "
        QEMU_BASE += "-tpmdev emulator,id=tpm0,chardev=chrtpm "
        QEMU_BASE += "-device tpm-tis,tpmdev=tpm0 "

    run_cmd(QEMU_BASE, dry_run=aa.dry)
    # print(QEMU_BASE)
