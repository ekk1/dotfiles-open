GO_VER="1.22.1"
GO_ROOT_DIR="$HOME/gogogo"

mkdir -p $GO_ROOT_DIR
cd $GO_ROOT_DIR
wget https://go.dev/dl/go${GO_VER}.linux-amd64.tar.gz
tar -xzvf go${GO_VER}.linux-amd64.tar.gz

echo "export PATH=\$PATH:$HOME/gogogo/go/bin:$HOME/go/bin"
