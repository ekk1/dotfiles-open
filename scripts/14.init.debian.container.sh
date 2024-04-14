# podman run --network=host -d --name dev debian:bookworm sleep infinity
# podman exec -it dev bash

# sed -i 's|http://deb.debian.org|http://mirrors.ustc.edu.cn|g' /etc/apt/sources.list.d/debian.sources
# apt update; apt install apt-transport-https ca-certificates
# sed -i 's|http://mirrors.ustc.edu.cn|https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list.d/debian.sources


# Vim related
apt install vim-nox vim-youcompleteme \
    vim-ctrlp vim-airline \
    vim-airline-themes vim-addon-manager \
    vim-ale

# Terminal tools
apt install ncdu htop tmux netcat-openbsd \
    wget curl iptables tig powerline ranger \
    rsync ripgrep tree \
# Coding related
apt install python3-httpbin python3-livereload fswatch
