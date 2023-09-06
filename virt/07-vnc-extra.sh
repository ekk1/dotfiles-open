sudo apt update
sudo apt install -y xfce4 xfce4-goodies

vncserver
vncserver -kill :1

mv ~/.vnc/xstartup ~/.vnc/xstartup.bak

cat >~/.vnc/xstartup <<EOF
# For Xfce4
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4
EOF

sudo chmod +x ~/.vnc/xstartup
sudo apt install -y tigervnc-standalone-server
vncserver -geometry 1280x720 -localhost

sudo apt install -y novnc python3-websockify

# websockify  --web=/usr/share/novnc/ 127.0.0.1:6801 127.0.0.1:5901
