import subprocess
import typing

def run_cmd(cmd: str, env: typing.Optional[dict]=None) -> subprocess.CompletedProcess:
    """run cmd"""
    return subprocess.run(
            ['bash', '-c' , cmd],
            capture_output=True,
            env=env
    )

