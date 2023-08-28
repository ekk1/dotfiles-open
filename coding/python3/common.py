import subprocess
import typing
import datetime

def run_cmd(cmd: str, env: typing.Optional[dict]=None) -> subprocess.CompletedProcess:
    """run cmd"""
    return subprocess.run(
            ['bash', '-c' , cmd],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            universal_newlines=True,
            env=env,
    )

def log_print(msg: str, level: typing.Optional[str]="INFO"):
    '''print with level and date'''
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print("[{0}][{1}]: {2}".format(now, level, msg))

