" apt install vim-airline
" apt install fonts-powerline
" apt install vim-ctrlp
" apt install vim-nox
" apt install vim-python-jedi
" apt install vim-voom
" apt install vim-fugitive
" apt install vim-gitgutter
" apt install vim-ale
" apt install vim-youcompleteme
" vam install youcomleteme

colorscheme elflord
syntax on
set nocompatible
filetype off

set tabstop=4  " number of visual spaces per TAB
set softtabstop=4  " number of spaces in tab when editing
set expandtab  " tabs are spaces
set shiftwidth=4

set relativenumber " show line numbers
set number
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
" Nature split
set splitbelow
set splitright
" Allow buffer to be hidden(switched)
set hidden

nnoremap <leader><space> :nohlsearch<CR>
nnoremap <leader><leader> :set relativenumber!<CR>:set number!<CR>
nnoremap <leader>. :CtrlPBuffer<CR>
nnoremap <leader>/ :bnext<CR>
nnoremap <leader>t :enew<CR>
nnoremap <leader>n :bnext<CR>
nnoremap <leader>p :bprevious<CR>
nnoremap <leader>l :ls<CR>
nnoremap <leader>q :bp <BAR> bd #<CR>
nnoremap <leader>w :bp <BAR> bd #<CR><C-W>w
" nnoremap <leader>q :bd<CR>

" Netrw related
if &columns < 90
  " If the screen is small, occupy half
  let g:netrw_winsize = 40
else
  " else take 30%
  let g:netrw_winsize = 25
endif

let g:netrw_keepdir = 0
let g:netrw_localcopydircmd = 'cp -r'
let g:netrw_liststyle = 3
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'
hi! link netrwMarkFile Search
nnoremap <leader>da :Lexplore %:p:h<CR>
nnoremap <leader>dd :Lexplore<CR>

function! NetrwMapping()
  " Close Netrw window
  nmap <buffer> <leader>dd :Lexplore<CR>
  nmap <buffer> <leader>da :Lexplore<CR>
  " Go to file and close Netrw window
  nmap <buffer> L <CR>:Lexplore<CR>
  " Go back in history
  nmap <buffer> H u
  " Go up a directory
  nmap <buffer> h -^
  " Go down a directory / open file
  nmap <buffer> l <CR><C-W>w
  " Toggle dotfiles
  nmap <buffer> . gh
  " Toggle the mark on a file
  nmap <buffer> <TAB> mf
  " Unmark all files in the buffer
  nmap <buffer> <S-TAB> mF
  " Unmark all files
  nmap <buffer> <Leader><TAB> mu
  " 'Bookmark' a directory
  nmap <buffer> bb mb
  " Delete the most recent directory bookmark
  nmap <buffer> bd mB
  " Got to a directory on the most recent bookmark
  nmap <buffer> bl gb
  " Create a file
  nmap <buffer> ff %:w<CR>:buffer #<CR>
  " Rename a file
  nmap <buffer> fe R
  " Copy marked files
  nmap <buffer> fc mc
  " Copy marked files in the directory under cursor
  nmap <buffer> fC mtmc
  " Move marked files
  nmap <buffer> fx mm
  " Move marked files in the directory under cursor
  nmap <buffer> fX mtmm
  " Execute a command on marked files
  nmap <buffer> f; mx
  " Show the list of marked files
  nmap <buffer> fl :echo join(netrw#Expose("netrwmarkfilelist"), "\n")<CR>
  " Show the current target directory
  nmap <buffer> fq :echo 'Target:' . netrw#Expose("netrwmftgt")<CR>
  " Set the directory under the cursor as the current target
  nmap <buffer> fd mtfq
  " Close the preview window
  nmap <buffer> P <C-w>z
endfunction

augroup netrw_mapping
    autocmd!
    autocmd filetype netrw call NetrwMapping()
augroup END

inoremap jkk <esc>
inoremap kjj <C-x><C-o>
nnoremap B ^
nnoremap E $
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
" map <F2> :NERDTreeToggle<cr>
" map <A-Down> :tabn<cr>
" map <A-Up> :tabp<cr>
" let g:ctrlp_map = '<c-p>'
" let g:ctrlp_cmd = 'CtrlP'

" Only for ref
" set paste

set autoindent
set mouse=c
let python_highlight_all = 1
set ruler

" fix ugly markdown error
hi link markdownError Normal

" CVE-2019-12735
set modelines=0
set nomodeline
filetype plugin indent on

" Add some plugins
packadd! CtrlP
" packadd! command-t
" packadd! ale
" Use YCM instead
" packadd! python-jedi

" Seems not necessary
" let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"

" More intelligent ycm complete triggers for web coding
let g:ycm_semantic_triggers = {
    \   'css': ['re!^\s{4}', 're!:\s+'],
    \   'html': ['re!<', 're!</'],
    \ }

let g:ycm_gopls_binary_path = "gopls"

" Airline Custom
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" CtrlP Custom
if executable('rg')
  let g:ctrlp_user_command = 'rg %s --files --hidden --color=never --glob ""'
endif
let g:ctrlp_use_caching = 0

" Allow code syntax inside markdown
let g:markdown_fenced_languages = ['python', 'bash', 'yaml']
let g:markdown_syntax_conceal = 0

" Show trailing white space as red
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
