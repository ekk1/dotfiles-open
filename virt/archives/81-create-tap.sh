#!/bin/bash
ip link add br0 type bridge
ip tuntap add dev tap0 mode tap
ip link set dev tap0 master br0
ip link set dev br0 up

ip addr add 192.168.123.1/24 dev br0

# TODO:
# Need NATed network setup
iptables -t nat -A POSTROUTING -s 192.168.123.0/24 -i br0 -j MASQUERATE ?


# QEMU param for tap
-netdev tap,id=mynet0,ifname=tap0
