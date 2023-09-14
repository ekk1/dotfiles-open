import subprocess

def run_cmd(cmd, verbose=True):
    s = subprocess.run(
        ["bash", "-c", cmd],
        stdout = 

    )

