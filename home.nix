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
    
  home = {
    file.".tmux.conf".source = ./dotfiles/tmux.conf;
    sessionVariables = {
      EDITOR = "nvim";
    };

    packages = with pkgs; [
      nodePackages.npm
      nodePackages.node2nix
    ];
  };
 
  programs = {

    home-manager = {
      enable = true;
      path = "https://github.com/rycee/home-manager/archive/master.tar.gz";
    };

    vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions =  with pkgs.vscode-extensions; [ 
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [ 
        {
          name = "nixfmt-vscode";
          publisher = "brettm12345";
          version = "0.0.1";
          sha256 = "07w35c69vk1l6vipnq3qfack36qcszqxn8j3v332bl0w6m02aa7k";
        }
        {
          name = "nix-env-selector";
          publisher = "arrterian";
          version = "0.1.2";
          sha256 = "1n5ilw1k29km9b0yzfd32m8gvwa2xhh6156d4dys6l8sbfpp2cv9";
        }
        {
          name = "svelte-vscode";
          publisher = "jamesbirtles";
          version = "0.9.3";
          sha256 = "0wfdp06hsx7j13k1nj63xs3pmp7zr6p96p2x45ikg3xrsvasghyn";
        }
        {
          name = "better-toml";
          publisher = "bungcip";
          version = "0.3.2";
          sha256 = "0wfdp06hsx7j13k1nj63xs3pmp7zr6p96p2x45ikg3xrsvasghyn";
        }
        {
          name = "Nix";
          publisher = "bbenoist";
          version = "1.0.1";
          sha256 = "0wfdp06hsx7j13k1nj63xs3pmp7zr6p96p2x45ikg3xrsvasghyn";
        }
        {
          name = "vim";
          publisher = "vscodevim";
          version = "1.11.3";
          sha256 = "0wfdp06hsx7j13k1nj63xs3pmp7zr6p96p2x45ikg3xrsvasghyn";
        }
        {
          name = "python";
          publisher = "ms-python";
          version = "2020.5.86806";
          sha256 = "0wfdp06hsx7j13k1nj63xs3pmp7zr6p96p2x45ikg3xrsvasghyn";
        }
      ];
    };

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
            vimproc
            # Utilities
            ctrlp
            neocomplete
  	  ];
	  opt = [];
        };
        customRC = builtins.readFile ./dotfiles/vimrc;
      };
    };

    git = {

      enable = true;
	
      userName = "Matan Shenhav";
      userEmail = "matan@fluxcraft.net";

      extraConfig = builtins.readFile ./dotfiles/gitconfig;
    };
  };
}
