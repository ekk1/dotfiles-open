syntax on
set nocompatible
filetype off

set tabstop=4  " number of visual spaces per TAB
set softtabstop=4  " number of spaces in tab when editing
set expandtab  " tabs are spaces
set shiftwidth=4

set relativenumber " show line numbers
set showcmd  " show command in bottom bar
set cursorline  " highlight current line
"filetype indent on  " load filetype-specific indent files

set wildmenu  " visual autocomplete for command menu
set lazyredraw  " redraw only when we need to.
set showmatch  " highlight matching [{()}]

set incsearch  " search as characters are entered
set hlsearch  " highlight matches
" turn off search highlight
let mapleader=","  " leader is comma
nnoremap <leader><space> :nohlsearch<CR>
nnoremap <leader><leader> :set relativenumber!<CR>
nnoremap <leader>. :set number<CR>

inoremap jk <esc>
" inoremap kj <C-x><C-o>
nnoremap B ^
nnoremap E $
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map <F2> :NERDTreeToggle<cr>
map <A-Down> :tabn<cr>
map <A-Up> :tabp<cr>

" Only for ref
" set paste

set autoindent
set mouse=c
let python_highlight_all = 1
set ruler

" CVE-2019-12735
set modelines=0
set nomodeline

" Vundle
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()

" let Vundle manage Vundle, required
"Plugin 'VundleVim/Vundle.vim'
"Plugin 'scrooloose/nerdtree'
"Plugin 'Yggdroot/LeaderF'
"call vundle#end()
filetype plugin indent on
