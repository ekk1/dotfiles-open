vam install youcompleteme
git clone https://github.com/ekk1/dotfiles-open.git
echo "/home/user/.vimrc" >> /home/user/.vim_jump_cache
cp dotfiles-open/tmux.conf .tmux.conf
cp dotfiles-open/make-vim-better/vimrc .vimrc
cat dotfiles-open/bashrc >> ~/.bashrc
exit
