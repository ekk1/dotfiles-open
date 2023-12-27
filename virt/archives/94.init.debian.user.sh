#!/bin/bash
vam install youcompleteme
echo "/home/$USER/.vimrc" >> /home/$USER/.vim_jump_cache
cp dots/tmux.conf .tmux.conf
cp make-vim-better/vimrc .vimrc
cat dots/bashrc >> ~/.bashrc
