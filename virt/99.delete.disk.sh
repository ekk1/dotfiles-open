#!/bin/bash

echo "Deleting"
rm -rf /dev/shm/virt
rm -rf /srv/vms/testvm-1.qcow2
rm -rf /srv/vms/testvmw-1.qcow2

ls -al /dev/shm/*
echo "listing /srv/vms"
ls -al /srv/vms
