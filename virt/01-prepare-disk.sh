# wget https://mirrors.ustc.edu.cn/debian-cdimage/cloud/bookworm/20230910-1499/debian-12-nocloud-amd64-20230910-1499.qcow2
# 50a3e1863088a61408a380ffa3364c4fc9ddb4860262f65dabc452721089c13d353b32386614b84072392bf25cc4659de47d3bcc65fec2ffaf4300a799b95f3b  debian-12-nocloud-amd64-20230910-1499.qcow2
# 0a895b53b04a974d5dced0ff8f1a0fd06bd3fa72fff3e21ec3815d5dd94d053fcf29bbac65a9f6918fa055b4c3b4bc716afce5de21cbaae1406118f5ac1321dc  debian-12-nocloud-amd64-20230910-1499.raw
#
# qemu-img convert -f qcow2 -O raw img.qcow2 img.raw

# curl -JLO https://gitlab.archlinux.org/archlinux/arch-boxes/-/package_files/4918/download
# verify with https://gitlab.archlinux.org/archlinux/arch-boxes

qemu-img create -f qcow2 -b debian-12-nocloud-amd64-20230910-1499.qcow2 -F qcow2 testvm-1.qcow2 20G
# qemu-img create -f qcow2 -b Arch-Linux-x86_64-basic-20230815.172076.qcow2 -F qcow2 testvm-1.qcow2 20G

