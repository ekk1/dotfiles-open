GO_VER="1.22.2"
GO_ROOT_DIR="$HOME/gogogo"

mkdir -p $GO_ROOT_DIR
cd $GO_ROOT_DIR
wget https://go.dev/dl/go${GO_VER}.linux-amd64.tar.gz

# These are pretty much needed
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest
