{ pkgs, ... }:
 
{
    
  home.file.".tmux.conf".source = ./tmux/tmux.conf;
 
  programs = {

    home-manager = {
      enable = true;
      path = "/home/ixxie/nixdev/home-manager";
    };

    zsh.enable = true;

    neovim = {
      enable = true;
      configure = {
        packages.myNeovimPackage = with pkgs.vimPlugins; {
          start = [
            # Interface
	    The_NERD_tree
            gitgutter
	    airline
            vim-airline-themes
            vim-colorschemes
            sensible
            supertab
            # Language Specific
            syntastic
            vim-nix
            python-mode
            # Utilities
            ctrlp
            neocomplete
  	  ];
	  opt = [];
        };
        customRC = ''

          " Interface "
          """""""""""""

          let mapleader = ";"
          set hidden
          
          set autoindent
          set updatetime=300
          set clipboard=unnamedplus
          set mouse+=a
          let g:SuperTabDefaultCompletionType = "<c-n>"


          " Appearance "
          """"""""""""""

          set t_Co=256
          colorscheme Benokai
          let g:airline_theme='powerlinesh'
          let g:airline_powerline_fonts=1
          
          syntax on
          set number
          let g:gitgutter_enabled = 1
          set fillchars+=vert:\ 

          " Nerd Tree "
          """""""""""""

          " start always
          autocmd vimenter * NERDTree

          " close when last
          let isLastBuffer = winnr("$") == 1 
           \ && exists("b:NERDTreeType") 
           \ && b:NERDTree.isTabTree() 
            
          autocmd bufenter * if isLastBuffer | q | endif

          " keybinding
          nnoremap <silent> <Leader>t :NERDTreeFind<CR>
          nnoremap <silent> <Leader>a :tabp<CR>
          nnoremap <silent> <Leader>d :tabn<CR>

          " minima UI
          let NERDTreeMinimalUI = 2
          let NERDTreeDirArrows = 1


          " Language Specific "
          """""""""""""""""""""

          " Python
          set statusline+=%#warningmsg#
          set statusline+=%{SyntasticStatuslineFlag()}
          set statusline+=%*
          let g:syntastic_always_populate_loc_list = 1
          let g:syntastic_auto_loc_list = 1
          let g:syntastic_check_on_open = 1
          let g:syntastic_check_on_wq = 0
          let g:syntastic_python_checkers=['python3', 'flake8']
          let g:syntastic_python_flake8_exec = 'flake8'

        '';
      };
    };

    git = {

      enable = true;
	
      userName = "Matan Shenhav";
      userEmail = "matan@fluxcraft.net";

      extraConfig = ''
	[color "branch"]
	  current = green bold
	  local = green
	  remote = yellow

	[color "diff"]
	  frag = cyan bold
	  meta = yellow bold
	  new = green
	  old = red

	[diff "bin"]
	  textconv = hexdump -v -C
      '';
    };
  };
}
