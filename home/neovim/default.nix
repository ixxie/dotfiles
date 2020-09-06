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
in {

  home.sessionVariables.EDITOR = "nvim";

  programs.neovim = {
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
        opt = [ ];
      };
      customRC = builtins.readFile ./vimrc;
    };
  };
}
