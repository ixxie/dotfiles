{ pkgs, ... }:

let
 
  rainglow = pkgs.vimUtils.buildVimPlugin {
    name = "vim-better-whitespace";
    src = pkgs.fetchFromGitHub {
      owner = "rainglow";
      repo = "vim";
      rev = "837fd7292274e0ee2f3b5aee4519c3f74d7dc3d1";
      sha256 = "0crwwq5fbw2vsr16l626c15xff03i326gvbj6rab85x2h6q7hvyy";
    };
  };

in

{
    
  home.file.".tmux.conf".source = ./tmux/tmux.conf;
 
  programs = {

    home-manager = {
      enable = true;
      path = "https://github.com/rycee/home-manager/archive/release-18.03.tar.gz";
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
            rainglow
            sensible
            supertab
            # Language Specific
            syntastic
            vim-nix
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
          
          let g:ctrlp_map = '<c-p>'
          let g:ctrlp_cmd = 'CtrlP'

          " window navigation
          nnoremap <M-Left>  <C-w>h
          nnoremap <M-Down>  <C-w>j
          nnoremap <M-Up>    <C-w>k
          nnoremap <M-Right> <C-w>l

          " buffer navigation
          nnoremap gp :bp<CR>
          nnoremap gn :bn<CR>
          nnoremap gl :ls<CR>
          nnoremap gb :ls<CR>:b

          " Appearance "
          """"""""""""""
          
          let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
          let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
          set termguicolors

          
          colorscheme freshcut

          " cool themes:
          " Benokai / Tonic / Freshcut / Goldfish / Bold
          " Coffee / Hive / Zacks / Jingle / Boxuk 

          let g:airline_theme='powerlineish'
          let g:airline_powerline_fonts=1
          set fillchars+=vert:\                                " pretty vertical splits
          
          syntax on
          set number
          let g:gitgutter_enabled = 1
          set signcolumn="yes"                                 " keep gutter even when empty  
          execute "set colorcolumn=".join(range(101,350),",")  

          " Nerd Tree "
          """""""""""""

          " keybinding
          map <c-x> :NERDTreeToggle<CR>

          let NERDTreeAutoDeleteBuffer = 1

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
