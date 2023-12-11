# wget https://cloud.debian.org/images/cloud/bookworm/20231210-1591/debian-12-genericcloud-amd64-20231210-1591.qcow2
# 7b7f4d34bba4a6a819dbd67ae338b46141646de7b18ae3818a7aa178d383bfbb3e9e0197c545bb2d5fd5be7f8e55a7d449b285983ae86a09a294124bb97d3d5f  debian-12-genericcloud-amd64-20231210-1591.qcow2
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
echo "wget https://cloud.debian.org/images/cloud/bookworm/20231210-1591/debian-12-genericcloud-amd64-20231210-1591.qcow2"
