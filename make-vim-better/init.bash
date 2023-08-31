for ii in autoload doc plugin syntax
do
    mkdir -p ~/.vim/$ii
done

cp /usr/share/vim/vim90/syntax/markdown.vim .vim/syntax/markdown.vim

# change these lines
vim .vim/syntax/markdown.vim
# syn match markdownListMarker "\%(\t\| \{0,32\}\)[-*+]\%(\s\+\S\)\@=" contained
# syn match markdownOrderedListMarker "\%(\t\| \{0,16}\)\<\d\+\.\%(\s\+\S\)\@=" contained

# edit vimrc
# change this line
# vimJumpCacheLocation
# CheetSheetLocation can be deleted
#
# use Space+m to save a file to avoid error

echo "[MESSAGES CONTROL]" > ~/.pylintrc
echo "disable=C0103" >> ~/.pylintrc
