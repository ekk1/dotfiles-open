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
sed -i "" "s|/user/|/$USER/|g" ~/.vimrc
sed -i "" "s|/home/|/Users/|g" ~/.vimrc

echo "$HOME/.vimrc" >> ~/.vim_jump_cache
