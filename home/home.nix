{ pkgs, ... }:

{
  imports = [
    ./neovim
    ./tmux
    ./git
    ./vscodium
  ];

  home = {
    packages = with pkgs; [
      nodePackages.npm
      nodePackages.node2nix
    ];
  };
 
  programs.home-manager = {
      enable = true;
      path = "https://github.com/rycee/home-manager/archive/master.tar.gz";
  };
}
