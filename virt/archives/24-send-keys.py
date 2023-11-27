#!/usr/bin/python3
import socket
import time
import string

ch_map = {
    "-": "minus",
    "=": "equal",
    ".": "dot",
    "/": "slash",
    "_": "shift-minus",
    ":": "shift-semicolon",
    ";": "semicolon",
    " ": "spc",
    "$": "shift-4",
    "'": "apostrophe",
    "\"": "shift-apostrophe",
    "[": "bracket_left",
    "`": "grave_accent",
    "~": "shift-grave_accent",
    ">": "shift-dot",
    "\\": "backslash",
}
lower_key = dict(zip(string.ascii_lowercase, string.ascii_lowercase))
upper_key = dict(zip(string.ascii_uppercase, list(map(lambda a: 'shift-'+a, string.ascii_lowercase))))
number_key = dict(zip(string.digits, string.digits))
key_mapping = ch_map | lower_key | upper_key | number_key

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("127.0.0.1", 6001))

chunk = s.recv(10240)
print(chunk)

cmds = [
    "root",
    "sleep 2",
    "ssh-keygen -A",
    "sleep 10",
    "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config",
    "sleep 2",
    "systemctl restart ssh",
    "sleep 2",
    "useradd -m -s /usr/bin/bash user",
    "sleep 2",
    "passwd user",
    "sleep 2",
    "123",
    "sleep 2",
    "123",
    "sleep 2",
    "passwd root",
    "sleep 2",
    "321",
    "sleep 2",
    "321",
    "sleep 2",
    "echo 'export PATH=$PATH:/sbin:/usr/sbin' >> /root/.bashrc",
    "sleep 2",
    "exit",
]

for cmd in cmds:
    if 'sleep ' in cmd:
        sleep_sec = int(cmd.split()[-1])
        print(f"sleep {sleep_sec}")
        time.sleep(sleep_sec)
        continue
    for ch in cmd:
        if ch in key_mapping:
            s.send(f'sendkey {key_mapping[ch]}\n'.encode())
        else:
            raise KeyError(f"No mapping of {ch} found")
        time.sleep(0.15)
    s.send(f'sendkey ret\n'.encode())
    chunk = s.recv(10240)
    print(chunk.decode())
    time.sleep(1)

