# for ii in autoload doc plugin syntax
# do
#     mkdir -p ~/.vim/$ii
# done
# cp /usr/share/vim/vim90/syntax/markdown.vim .vim/syntax/markdown.vim

### change these lines
# vim .vim/syntax/markdown.vim
# syn match markdownListMarker "\%(\t\| \{0,32\}\)[-*+]\%(\s\+\S\)\@=" contained
# syn match markdownOrderedListMarker "\%(\t\| \{0,16}\)\<\d\+\.\%(\s\+\S\)\@=" contained

cp vimrc ~/.vimrc
mkdir -p ~/.vim/pack/git-plugins/start/
cp 3rdparty/ale-deb ~/.vim/pack/git-plugins/start/
cp 3rdparty/vim-airline ~/.vim/pack/git-plugins/start/
cp 3rdparty/ctrlp.vim-deb ~/.vim/pack/git-plugins/start/
