# qemu-img create -f qcow2 base.qcow2 50G

DEBIAN_IMG="debian-13-genericcloud-amd64-20250814-2204.qcow2"

if [[ ! -f ${DEBIAN_IMG} ]] ; then
    echo "Please download debian image first"
    exit 0
fi

if [[ ! -f base.qcow2 ]] ; then
    echo "Creating base disk"
    qemu-img create -f qcow2 -b ${DEBIAN_IMG} -F qcow2 base.qcow2 20G
fi

if [[ ! -f user-data ]] ; then
    echo "Creating userdata"
cat >user-data <<EOF
#cloud-config
ssh_authorized_keys:
  - ssh-rsa xxx
EOF
fi

if [[ ! -f meta-data ]] ; then
    echo "Creating metadata"
cat >meta-data <<EOF
local-hostname: "vm"
EOF
fi

if [[ ! -f meta.iso ]] ; then
    echo "Creating meta iso"
    genisoimage -output meta.iso -volid cidata -joliet -rock user-data meta-data
fi
