"
" Colors
" " " " "
set background=dark
colorscheme base16-eighties
let base16colorspace=256

"
" General
" " " " "
set number
set relativenumber
set history=500
set autoread
set showcmd
set showmode
set nocompatible
set nobackup
set nowritebackup
set noswapfile
filetype plugin on
let g:autoclose_vim_commentmode = 1 	" for vim-autoclose plugin

"
" Format
" " " " "
set autoindent
set smartindent
set smarttab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab
set list listchars=tab:\ \ ,trail:·
set colorcolumn=80
set showmatch
syntax on

"
" Syntastic
" " " " " "
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

"
" Airline
" " " " "
set laststatus=2	" always show airline
let g:airline#extensions#tabline#enabled = 1 " show tabline

