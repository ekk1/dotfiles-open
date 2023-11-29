"""some commons"""
import subprocess
import datetime

def run_cmd(cmd, env=None):
    """run cmd"""
    return subprocess.run(
        ['bash', '-c' , cmd],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        universal_newlines=True,
        env=env,
        check=False,
    )

def log_print(msg, level="INFO"):
    '''print with level and date'''
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{now}][{level}]: {msg}")
