# wget https://mirrors.ustc.edu.cn/debian-cdimage/cloud/bookworm/20231013-1532/debian-12-genericcloud-amd64-20231013-1532.qcow2
# 6b55e88b027c14da1b55c85a25a9f7069d4560a8fdb2d948c986a585db469728a06d2c528303e34bb62d8b2984def38fd9ddfc00965846ff6e05b01d6e883bfe  debian-12-genericcloud-amd64-20231013-1532.qcow2
#
# qemu-img convert -f qcow2 -O raw img.qcow2 img.raw

if [[ ! $UID -eq 0 ]]; then
    echo "Please run this as root"
    exit 1
fi

base_dir="/srv/vms"
base_ram_dir="/dev/shm/virt"
mkdir -p ${base_dir}
mkdir -p ${base_ram_dir}
chmod 700 ${base_dir}
chmod 700 ${base_ram_dir}
chown $USER:$USER ${base_dir}
chown $USER:$USER ${base_ram_dir}

echo "please download images to /srv/vms"
echo "wget https://cloud.debian.org/images/cloud/bookworm/20231013-1532/debian-12-genericcloud-amd64-20231013-1532.qcow2"
