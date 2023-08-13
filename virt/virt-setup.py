import requests
import subprocess

def run_cmd(cmd: str) -> (int, bytes, bytes):
    p = subprocess.run(["bash", "-c", cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    return p.returncode, p.stdout, p.stderr

def get_image(image_name: str):
    image_list = {
        "debian11": {
            "url": "https://cloud.debian.org/images/cloud/bookworm/20230802-1460/debian-12-nocloud-amd64-20230802-1460.qcow2",
            "checksum": "a430f77dab0fb2363ddd613b198d1b8c7c4e2cb8cbff90c38a345bbf2edd3d4d1007328a4535145dda2555d3c76eba5ea91d474f15f246f95a86cbe1affd6509"
        }
    }
    if image_name in image_list:
        print(f"Downloading {image_name} from {image_list[image_name]['url']}")
        # TODO: Download and verify

def generate_base_image(file_name: str, base_image_name: str, size: int):
    run_cmd(f"qemu-img create -f qcow2 -b {base_image_name} -F qcow2 {file_name} {size}G")

