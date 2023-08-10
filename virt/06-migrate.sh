TCP example:

1. Start the VM on B with the exact same parameters as the VM on A, in migration-listen mode:

B: <qemu-command-line> -incoming tcp:0:4444 (or other PORT))


2. Start the migration (always on the source host):

A: migrate -d tcp:B:4444 (or other PORT)


3. Check the status (on A only):

A: (qemu) info migrate

