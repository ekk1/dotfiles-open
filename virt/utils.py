import subprocess
import datetime

def log_print(msg, level="INFO"):
    '''print with level and date'''
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{now}][{level}]: {msg}")

def run_cmd(cmd: str, env=None, verbose=False, dry_run=False):
    """run cmd"""
    log_print(f"Running {cmd}")
    if dry_run:
        log_print("DRY RUN MODE, skipping exec")
        return ""
    s = subprocess.run(
            ['bash', '-c' , cmd],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            universal_newlines=True,
            env=env,
            check=False,
    )
    if verbose:
        log_print(s.stdout)
        log_print(s.stderr)
    return s
