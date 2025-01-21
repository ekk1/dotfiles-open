#!/bin/bash
set -o errexit
# set -o xtrace
# alias vm='cd isodir; bash /path/to/31.xxx'
# qemu -device ?
# qemu -device vga,?
# possible useful virgl 3D acceleration
# qemu-system-x86_64 -device virtio-gpu-pci,virgl=on -display gtk,gl=on

# privoxy config
# trustfile trust
# debug 1 512 1024 4096 8192

# trustfile
# +mirrors.ustc.edu.cn

# For a typical archlinux install
# first download arch image and gpg file, and verify it
# now run
# vm test archlinux.iso a aa (this is kvm install
# this should open archlinux and auto enable it to tty
# login with root, and passwd
# now C+] exits
# vm test arch.iso sf + s to login ssh
# follow install procedure
#
# Use guestfwd=tcp:10.0.2.100:8118-tcp:127.0.0.1:8118   (one time)
# Use 'user...guestfwd=tcp:10.0.2.100:8118-cmd:nc 127.0.0.1 8118'   (all the time)
# to allow guest access http proxy directly
#
# For windows XP install, modify some parameters
# -m 2G  -hda winxp.qcow2 -cdrom xp.iso -device rtl8139,netdev=netout -vga cirrus (no -machine)

if [[ -z $1 || -z $2 || -z $3 ]] ; then
    echo "ssh sa@127.0.0.1 -p 2221 -R 127.0.0.1:8118:127.0.0.1:8118 -L 127.0.0.1:11434:127.0.0.1:11434 -L 127.0.0.1:7777:127.0.0.0.1:7777"
    echo "bash 31.create.vm.sh disk cdrom action [kvm] [dry]"
    echo "disk dont need qcow2 suffix"
    echo "cdrom is a must"
    echo "action: "
    echo "when stopped: "
    echo '    q: query'
    echo '    w: windows'
    echo '    s: start'
    echo '    a: archlinux install'
    echo '    aa: help for archlinux install'
    echo "when running: "
    echo '    q: query'
    echo '    v: vnc'
    echo '    k: kill'
    echo '    s: ssh'
    echo '    sa: ssh sa'
    echo '    sf: forget'
    echo '    ss: serial'
    exit 0
fi

if ps aux | grep qemu | grep testvm ; then
    echo "Already started"
    if [[ ! -z $3 ]]; then
        if [[ $3 == "v" ]]; then
            echo "connect to vnc"
            vncviewer 127.0.0.1:5911
            echo "Done"
            exit 0
            echo "This shouldn't happen..."
        elif [[ $3 == "q" ]]; then
            echo "Started"
            exit 0
            echo "This shouldn't happen..."
        elif [[ $3 == "k" ]]; then
            echo "Terminating"
            pid=$(ps aux | grep qemu | grep testvm | awk '{print $2}')
            kill $pid
            echo "Done"
            exit 0
            echo "This shouldn't happen..."
        elif [[ $3 == "s" || $3 == "sa" ]]; then
            echo "connect to ssh"
            echo "-------------RUN THIS IN VM-----------------"
            echo "export https_proxy=http://127.0.0.1:8118"
            echo "export http_proxy=http://127.0.0.1:8118"
            echo "-------------RUN THIS IN VM-----------------"
            if [[ $3 == "sa" ]] ; then
                echo "ssh sa@127.0.0.1 -p 2221 -R 127.0.0.1:8118:127.0.0.1:8118 -L 127.0.0.1:11434:127.0.0.1:11434 -L 127.0.0.1:7777:127.0.0.0.1:7777"
                ssh sa@127.0.0.1 -p 2221 -R 127.0.0.1:8118:127.0.0.1:8118 -L 127.0.0.1:11434:127.0.0.1:11434 -L 127.0.0.1:7777:127.0.0.0.1:7777
            else
                ssh root@127.0.0.1 -p 2221 -R 127.0.0.1:8118:127.0.0.1:8118
            fi
            echo "Done"
            exit 0
            echo "This shouldn't happen..."
        elif [[ $3 == "ss" ]]; then
            echo "connect to serial"
            telnet 127.0.0.1 5001
            echo "Done"
            exit 0
            echo "This shouldn't happen..."
        elif [[ $3 == "sf" ]]; then
            echo "forgetting"
            ssh-keygen -R "[127.0.0.1]:2221"
            echo "Done"
            exit 0
            echo "This shouldn't happen..."
        else
            echo "Not defined action: $3"
            exit 0
            echo "This shouldn't happen..."
        fi
    else
        exit 0
    fi
else
    if [[ ! -z $3 ]] ; then
        if [[ $3 == "q" ]]; then
            echo "Not started"
            exit 0
            echo "This shouldn't happen..."
        elif [[ $3 == "s" || $3 == "w" || $3 == "a" ]] ; then
            echo "Starting vm"
        elif [[ $3 == "aa" ]] ; then
            echo "Installing archlinux"
            echo "first download arch image and gpg file, and verify it"
            echo "run vm test archlinux.iso a aa (this is kvm install"
            echo "this should open archlinux and auto enable it to tty"
            echo "login with root, and passwd"
            echo "now C+] exits"
            echo "vm test arch.iso sf + s to login ssh"
            echo "follow install procedure"
            exit 0
            echo "This shouldn't happen..."
        else
            echo "Not defined action: $3"
            exit 0
            echo "This shouldn't happen..."
        fi
    fi
fi

if [[ ! -f $1.qcow2 ]] ; then
    echo "No disk file, creating"
    qemu-img create -f qcow2 $1.qcow2 20G
    chmod 600 $1.qcow2
fi

if [[ ! -f $2 ]] ; then
    echo "ISO file not found!!!"
    exit 1
fi

basic_params="qemu-system-x86_64"

if [[ $3 == "w" ]] ; then
    echo "Create windows"
    basic_params+=" -m 8G -smp 4"
    basic_params+=" -drive file=$1.qcow2"
    basic_params+=" -cdrom $2"
    basic_params+=" -netdev user,id=netout,hostname=testvmw,restrict=on,hostfwd=tcp:127.0.0.1:2231-:3389"
    basic_params+=" -device e1000,netdev=netout"
    basic_params+=" -usb -device usb-tablet"
    basic_params+=" -machine pc-q35-7.2"
    basic_params+=" -name \"testvmw\""
    basic_params+=" -boot menu=on"
else
    echo "Create simple linux"
    basic_params+=" -m 4G -smp 2"
    basic_params+=" -drive file=$1.qcow2,if=virtio"
    if [[ $3 == "a" ]]; then
        basic_params+=" -cdrom $2"
    fi
    basic_params+=" -netdev user,id=netout,hostname=testvm,restrict=on,hostfwd=tcp:127.0.0.1:2221-:22"
    basic_params+=" -device virtio-net,netdev=netout"
    basic_params+=" -device virtio-rng-pci"
    basic_params+=" -name \"testvm\""
    basic_params+=" -boot d"
fi

basic_params+=" -vnc 127.0.0.1:11"
basic_params+=" -monitor tcp:127.0.0.1:6001,server,nowait"
basic_params+=" -serial tcp:127.0.0.1:5001,server,nowait"
basic_params+=" -sandbox on"
basic_params+=" -daemonize"
basic_params+=" -display none"

if [[ ! -z $4 ]] ; then
    echo "Enable KVM"
    basic_params+=" -enable-kvm -cpu host"
fi

if [[ ! -z $5 ]] ; then
    echo "Dryrun"
    echo "Running $basic_params"
else
    echo "Running $basic_params"
    $basic_params
    if [[ $3 == "a" ]] ; then
        echo "Triggering Archlinux install"
        sleep 1
        echo "sendkey tab" | nc -q 1 127.0.0.1 6001
        echo " console=ttyS0,115200" | nc -q 1 127.0.0.1 5001
        telnet 127.0.0.1 5001
    fi
fi
