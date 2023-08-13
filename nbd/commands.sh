nbd-client -l 127.0.0.1
nbd-client -name test-nbd 127.0.0.1 /dev/nbd0
nbd-client -d /dev/nbd0
