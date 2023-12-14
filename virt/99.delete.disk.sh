#!/bin/bash

echo "Deleting"
rm -rf /dev/shm/virt
rm -rf /srv/vms/testvm*.qcow2

rm seed*
rm user-data

ls -al /dev/shm/*
echo "listing /srv/vms"
ls -al /srv/vms
