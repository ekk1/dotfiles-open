# curl https://cloud.debian.org/images/cloud/bookworm/20230802-1460/debian-12-nocloud-amd64-20230802-1460.qcow2 -JLO
# echo "SHA512: a430f77dab0fb2363ddd613b198d1b8c7c4e2cb8cbff90c38a345bbf2edd3d4d1007328a4535145dda2555d3c76eba5ea91d474f15f246f95a86cbe1affd6509"
# raw: SHA512:033b2f6e61e1445801659113049b3a6486a3036e8f7076f81555664ae929b899522e7a686d56251eab000bd78a0c2144453b2ef6ef45394cb6e9c66460b1b00f  debian
# qemu-img convert -f qcow2 -O raw img.qcow2 img.raw

qemu-img create -f qcow2 -b debian-12-nocloud-amd64-20230802-1460.qcow2 -F qcow2 testvm-1.qcow2 20G

