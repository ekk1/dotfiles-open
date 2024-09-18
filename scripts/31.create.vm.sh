#!/bin/bash
set -o errexit
# set -o xtrace
# alias vm='cd isodir; bash /path/to/31.xxx'
# qemu -device ?
# qemu -device vga,?
# possible useful virgl 3D acceleration
# qemu-system-x86_64 -device virtio-gpu-pci,virgl=on -display gtk,gl=on

if [[ -z $1 || -z $2 || -z $3 ]] ; then
    echo "bash 31.create.vm.sh disk cdrom action [kvm] [dry]"
    echo "disk dont need qcow2 suffix"
    echo "cdrom is a must"
    echo "action: "
    echo "when stopped: "
    echo '    q: query'
    echo '    w: windows'
    echo '    s: start'
    echo '    a: archlinux install'
    echo "when running: "
    echo '    q: query'
    echo '    v: vnc'
    echo '    k: kill'
    echo '    s: ssh'
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
        elif [[ $3 == "s" ]]; then
            echo "connect to ssh"
            echo "-------------RUN THIS IN VM-----------------"
            echo "export https_proxy=http://127.0.0.1:8118"
            echo "export http_proxy=http://127.0.0.1:8118"
            echo "-------------RUN THIS IN VM-----------------"
            ssh root@127.0.0.1 -p 2221 -R 127.0.0.1:8118:127.0.0.1:8118
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
        else
            echo "Not defined action: $3"
            exit 0
            echo "This shouldn't happen..."
        fi
    fi
fi

if [[ ! -f $1 ]] ; then
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
    basic_params+=" -cdrom $2"
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
