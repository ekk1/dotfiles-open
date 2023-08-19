with open('/dev/nbd0', 'wb') as f:
    for ii in range(0, 100):
        f.write(str(ii).encode() * 128 * 1024)
