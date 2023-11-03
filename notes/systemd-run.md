
```bash
vim /etc/systemd/system/my.slice

[Slice]
CPUQuota=30%


systemctl daemon-reload


# Other service can run with
[Service]
Slice=my.slice

# Once off command
systemd-run --slice=my.slice command
systemd-run --uid=username --slice=my.slice command

--shell can run a shell
# Spawn a limit cpu shell to run cmds
systemd-run --uid=username --slice=my.slice --shell

# For non-root user
# The user slice files can be placed in ~/.config/systemd/user/
systemd-run --user --slice=my.slice command
systemd-run --user --slice=my.slice --shell
```

