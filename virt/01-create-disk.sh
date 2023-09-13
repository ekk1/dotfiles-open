#!/bin/bash
qemu-img create -f qcow2 -b debian-12-nocloud-amd64-20230910-1499.qcow2 -F qcow2 testvm-1.qcow2 20G
chmod 600 testvm-1.qcow2
