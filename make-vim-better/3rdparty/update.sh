rm -rf ale
mkdir -p ale
cp -r ../../../vimthings/ale/ale_linters    ale/
cp -r ../../../vimthings/ale/autoload       ale/
cp -r ../../../vimthings/ale/doc            ale/
cp -r ../../../vimthings/ale/ftplugin       ale/
cp -r ../../../vimthings/ale/lspconfig.vim  ale/
cp -r ../../../vimthings/ale/lua            ale/
cp -r ../../../vimthings/ale/plugin         ale/
cp -r ../../../vimthings/ale/rplugin        ale/
cp -r ../../../vimthings/ale/syntax         ale/
cp -r ../../../vimthings/ale/README.md      ale/

chmod 644 ale/ale_linters/php/intelephense.vim

rm -rf ctrlp.vim
mkdir -p ctrlp.vim
cp -r ../../../vimthings/ctrlp.vim/autoload     ctrlp.vim/
cp -r ../../../vimthings/ctrlp.vim/doc          ctrlp.vim/
cp -r ../../../vimthings/ctrlp.vim/plugin       ctrlp.vim/
cp -r ../../../vimthings/ctrlp.vim/readme.md    ctrlp.vim/

#rm -rf nerdtree
#mkdir -p nerdtree
#cp -r ../../../vimthings/nerdtree/autoload          nerdtree/
#cp -r ../../../vimthings/nerdtree/doc               nerdtree/
#cp -r ../../../vimthings/nerdtree/lib               nerdtree/
#cp -r ../../../vimthings/nerdtree/nerdtree_plugin   nerdtree/
#cp -r ../../../vimthings/nerdtree/plugin            nerdtree/
#cp -r ../../../vimthings/nerdtree/README.markdown   nerdtree/
#cp -r ../../../vimthings/nerdtree/syntax            nerdtree/
#
#rm -rf vim-airline
#mkdir -p vim-airline
#cp -r ../../../vimthings/vim-airline/autoload       vim-airline/
#cp -r ../../../vimthings/vim-airline/doc            vim-airline/
#cp -r ../../../vimthings/vim-airline/plugin         vim-airline/
#cp -r ../../../vimthings/vim-airline/README.md      vim-airline/
