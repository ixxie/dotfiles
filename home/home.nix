{ pkgs, ... }:

{
  imports = [ ./neovim ./tmux ./git ./vscodium ./fish ];

  programs.home-manager = {
    enable = true;
    path = "https://github.com/rycee/home-manager/archive/master.tar.gz";
  };
}
