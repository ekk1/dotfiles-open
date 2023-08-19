# curl https://cloud.debian.org/images/cloud/bookworm/20230802-1460/debian-12-nocloud-amd64-20230802-1460.qcow2 -JLO
# echo "SHA512: a430f77dab0fb2363ddd613b198d1b8c7c4e2cb8cbff90c38a345bbf2edd3d4d1007328a4535145dda2555d3c76eba5ea91d474f15f246f95a86cbe1affd6509"

qemu-img create -f qcow2 -b debian-12-nocloud-amd64-20230802-1460.qcow2 -F qcow2 testvm-1.qcow2 20G



