## Useful QEMU flags

```bash
# Performance related
    # -enable-kvm \
    # -m 32G -smp 8 \

# Create a netshare nic, hosting server will use listen, other servers use connect to join the same network
    # -netdev socket,id=netshare,listen=127.0.0.1:3333 \
    # -netdev socket,id=netshare,connect=127.0.0.1:3333 \
    # -device virtio-net,netdev=netshare \

# Use unix socket for monitor, and how to connect to it
    # -monitor unix:/tmp/monitor.sock,server,nowait \
    # nc -U /tmp/monitor.sock

```
