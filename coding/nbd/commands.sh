# Client parts

apt install nbd-client
modprobe nbd
nbd-client -l 127.0.0.1
nbd-client -name test-nbd 127.0.0.1 /dev/nbd0
nbd-client -d /dev/nbd0

# Server parts
apt install python3-requests
apt install python3-flask
apt install python3-eventlet
apt install gunicorn

gunicorn -w 1 'index:app'
# Use eventlet to enable http keepalive
gunicorn -w 1 -k eventlet 'index:create_index_app()'
