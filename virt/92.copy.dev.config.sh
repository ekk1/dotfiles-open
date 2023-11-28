#!/bin/bash
scp -P 2222 -i vm_key -r ../dots ../make-vim-better user@127.0.0.1:
