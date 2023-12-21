./32.list.dir.sh
./31.list.vm.sh

./23-kill-vm.sh
./99.delete.disk.sh

./32.list.dir.sh

sleep 1
./31.list.vm.sh

for ii in {2221..2230}; do ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "[127.0.0.1]:$ii" ; done
