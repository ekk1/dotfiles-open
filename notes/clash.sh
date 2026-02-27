#!/bin/bash

sysctl -w net.ipv4.ip_forward=1 > /dev/null

ip rule del fwmark 1 table 100 2>/dev/null
ip route flush table 100 2>/dev/null

ip rule add fwmark 1 table 100
ip route add local 0.0.0.0/0 dev lo table 100

iptables -t mangle -D PREROUTING -j CLASH 2>/dev/null
iptables -t mangle -F CLASH 2>/dev/null
iptables -t mangle -X CLASH 2>/dev/null

iptables -t mangle -N CLASH

iptables -t mangle -A CLASH -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH -d 169.254.0.0/16 -j RETURN
iptables -t mangle -A CLASH -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A CLASH -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A CLASH -d 240.0.0.0/4 -j RETURN

iptables -t mangle -A CLASH -p udp -j TPROXY --on-port 7893 --on-ip 127.0.0.1 --tproxy-mark 1
iptables -t mangle -A PREROUTING -j CLASH

iptables -F
iptables -X
iptables -P INPUT DROP
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -P FORWARD DROP

iptables -t nat -F

iptables -t nat -A PREROUTING -s 192.168.0.0/24 -p tcp -d 192.168.0.0/24 -j RETURN
iptables -t nat -A PREROUTING -s 192.168.0.0/24 -p tcp -j REDIRECT --to-ports 7892
