# apt update
# apt install vim-ale vim-ctrlp vim-airline vim-airline-themes

rm -rf ale
mkdir -p ale
cp -r /usr/share/vim-ale/*      ale/

rm -rf ctrlp.vim
mkdir -p ctrlp.vim
cp -r /usr/share/vim-ctrlp/*    ctrlp.vim/

rm -rf vim-airline
mkdir -p vim-airline
cp -r /usr/share/vim-airline/*  vim-airline/
