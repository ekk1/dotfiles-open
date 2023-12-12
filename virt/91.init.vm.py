#!/bin/python3
import argparse
import subprocess

def run_cmd(cmd, env=None, dry_run=False):
    """run cmd"""
    print("Running: ", cmd)
    if not dry_run:
        _ss = subprocess.run(
            ['bash', '-c' , cmd],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            universal_newlines=True,
            env=env,
            check=False,
        )
        print(_ss.stdout)
        print(_ss.stderr)

pp = argparse.ArgumentParser()
pp.add_argument('-m', '--multi',    type=int, help="multiple")
pp.add_argument('-a', '--apt',      type=str, help="apt host", default="mirrors.ustc.edu.cn")
pp.add_argument('-d', '--dry',      action="store_true", help="show commands but not exec")
pp.add_argument('-n', '--http',     action="store_true", help="use http for apt")
pp.add_argument('-p', '--proxy',    action="store_true", help="install privoxy for http proxy")
pp.add_argument('-q', '--dev',      action="store_true", help="install dev env")
aa = pp.parse_args()

_multi_qemu = 1
if aa.multi is not None:
    _multi_qemu = aa.multi

_nohttps = " 1" if aa.http else ""

for _vm_no in range(0, _multi_qemu):
    run_cmd(f"ssh-keygen -f \"/home/$USER/.ssh/known_hosts\" -R \"[127.0.0.1]:{2221 + _vm_no}\"", dry_run=aa.dry)
    run_cmd(f"scp -P {2221 + _vm_no} -i vm_key 93.init.debian.root.sh debian@127.0.0.1:", dry_run=aa.dry)
    run_cmd(f"scp -P {2221 + _vm_no} -i vm_key 94.init.debian.user.sh debian@127.0.0.1:", dry_run=aa.dry)
    run_cmd(f"scp -P {2221 + _vm_no} -i vm_key 94.init.debian.user.sh user@127.0.0.1:", dry_run=aa.dry)
    run_cmd(f"scp -P {2221 + _vm_no} -i vm_key -r ../dots ../make-vim-better debian@127.0.0.1:", dry_run=aa.dry)
    run_cmd(f"scp -P {2221 + _vm_no} -i vm_key -r ../dots ../make-vim-better user@127.0.0.1:", dry_run=aa.dry)
    run_cmd(f"ssh -R 9050 -p {2221 + _vm_no} debian@127.0.0.1 -i vm_key sudo bash 93.init.debian.root.sh {aa.apt}{_nohttps}", dry_run=aa.dry)
    if aa.proxy:
        print("Install privoxy")
    if aa.dev:
        print("Install dev")

# Run this is init user for dev
# ssh -R 9050 -p 2222 user@127.0.0.1 -i vm_key bash 94.init.debian.user.sh
