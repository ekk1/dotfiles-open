#!/bin/bash
ssh -R 9050 -p 2221 debian@127.0.0.1 -i vm_key
# Outside HTTP Proxy
# -R 8118:xxxx:8118
# Local Port forward
# -L 127.0.0.1:xxxx:127.0.0.1:xxxx
# If outside socks5 proxy presents
# ssh -R 9050:host:port -p 2221 user@127.0.0.1
