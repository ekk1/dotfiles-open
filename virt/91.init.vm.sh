#!/bin/bash

ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "[127.0.0.1]:2222"

scp -P 2222 -i vm_key 93.init.debian.root.sh debian@127.0.0.1:
scp -P 2222 -i vm_key 94.init.debian.user.sh user@127.0.0.1:
scp -P 2222 -i vm_key -r ../dots ../make-vim-better user@127.0.0.1:

ssh -R 9050 -p 2222 debian@127.0.0.1 -i vm_key sudo bash 93.init.debian.root.sh
# Run this is init user for dev
# ssh -R 9050 -p 2222 user@127.0.0.1 -i vm_key bash 94.init.debian.user.sh
