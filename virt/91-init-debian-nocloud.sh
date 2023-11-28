#!/bin/bash
scp -P 2222 -i vm_key 92-init-debian-root.sh 93-init-debian-dev.sh 94-init-debian-user.sh 95-init-debian-gui.sh user@127.0.0.1:
