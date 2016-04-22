"
" Colors
" " " " "
set background=dark
colorscheme base16-eighties

"
" General
" " " " "
set number
set history=500
set autoread
set showcmd
set showmode
set nocompatible
set nobackup
set nowritebackup
set noswapfile
filetype off
filetype plugin indent on
let g:autoclose_vim_commentmode = 1 	" for vim-autoclose plugin


"
" Format
" " " " "
set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set list listchars=tab:\ \ ,trail:·
set colorcolumn=80
set showmatch
syntax on

"
" Vundle
" " " " "
" Following script stolen from: 
" (http://erikzaadi.com/2012/03/19/auto-installing-vundle-from-your-vimrc/)
let hasVundle=1
let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
if !filereadable(vundle_readme) 
    echo "Installing Vundle.."
    echo ""
    silent !mkdir -p ~/.vim/bundle
    silent !git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/vundle
    let hasVundle=0
endif
set rtp+=~/.vim/bundle/vundle
call vundle#begin()
" Plugins:
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/syntastic'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'spf13/vim-autoclose'
" Plugins end
if hasVundle == 0
    echo "Installing Vundles, please ignore key map error messages"
    echo ""
    :PluginInstall
endif
call vundle#end()

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

