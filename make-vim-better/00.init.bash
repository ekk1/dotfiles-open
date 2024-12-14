# for ii in autoload doc plugin syntax
# do
#     mkdir -p ~/.vim/$ii
# done
# cp /usr/share/vim/vim90/syntax/markdown.vim .vim/syntax/markdown.vim

### change these lines
# vim .vim/syntax/markdown.vim
# syn match markdownListMarker "\%(\t\| \{0,32\}\)[-*+]\%(\s\+\S\)\@=" contained
# syn match markdownOrderedListMarker "\%(\t\| \{0,16}\)\<\d\+\.\%(\s\+\S\)\@=" contained

echo "[MESSAGES CONTROL]" > ~/.pylintrc
echo "disable=C0103" >> ~/.pylintrc
cp vimrc ~/.vimrc

# Install Outline
mkdir -p ~/.vim/ftplugin ~/.vim/lib/ftfunctions ~/.vim/plugin ~/.vim/syntax
cp ftplugin/*.vim ~/.vim/ftplugin/
cp lib/*.vim ~/.vim/lib/
cp lib/ftfunctions/*.vim ~/.vim/lib/ftfunctions/
cp plugin/*.vim ~/.vim/plugin/

# Install 3rd-party plugins (from debian's repo)
mkdir -p ~/.vim/pack/git-plugins/start/
cp -r 3rdparty/ale-deb ~/.vim/pack/git-plugins/start/
cp -r 3rdparty/vim-airline ~/.vim/pack/git-plugins/start/
cp -r 3rdparty/ctrlp.vim-deb ~/.vim/pack/git-plugins/start/
