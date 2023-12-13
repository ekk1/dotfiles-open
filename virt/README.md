## Useful QEMU flags

* quick cmds

```bash
./00.prepare.image.sh
./01.generate.meta.sh

# For windows guests, first install with no backing store, then rename it to windows.base, and use this as backing store
./11.create.server.py -r -k -x -m 2 -d /srv/vms/debian-12xxxx

././91.init.vm.py -m 2 -d -a 192.168.xxx -n

./52.quick.purge.debian.sh

# CHECK scripts/12.init-debian.sh for gpu #
```
