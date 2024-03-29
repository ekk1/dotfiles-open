#!/bin/bash
set -o errexit

ssh-keygen -t ed25519 -f vm_key -N ""

key_data=$(cat vm_key.pub)
sed "s|__SSH_PUB_KEY__|${key_data}|" user-data-template > user-data
genisoimage -output seed.iso -volid cidata -joliet -rock user-data meta-data
