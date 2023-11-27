# wget https://mirrors.ustc.edu.cn/debian-cdimage/cloud/bookworm/20231013-1532/debian-12-nocloud-amd64-20231013-1532.qcow2
# wget https://cloud.debian.org/images/cloud/bookworm/20231013-1532/debian-12-genericcloud-amd64-20231013-1532.qcow2
# 33f0fea16bec9240686a3c8533670d1d7bb03eab58c0d628623d02dc8a871155a17464a17489260b127e18062ec2fb2ee64d17259f71093f7bf9465e6e7d1872  debian-12-nocloud-amd64-20231013-1532.qcow2
# 1b91ebd04e31a687e8a419c409364a294f5475d50de62b168c89775e45dc472310bdddf547f8a216054f6b0f523bc87439c9a02f64bc841b3dc56cabfdc216ba  debian-12-nocloud-amd64-20231013-1532.raw
# 6b55e88b027c14da1b55c85a25a9f7069d4560a8fdb2d948c986a585db469728a06d2c528303e34bb62d8b2984def38fd9ddfc00965846ff6e05b01d6e883bfe  debian-12-genericcloud-amd64-20231013-1532.qcow2
#
# qemu-img convert -f qcow2 -O raw img.qcow2 img.raw
genisoimage  -output seed.iso -volid cidata -joliet -rock user-data meta-data
