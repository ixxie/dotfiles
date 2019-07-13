{ config, pkgs, ... }: 

{
  imports = [
    ./pkgs.nix
    ./gnome.nix
    ./gaming.nix
    ./xserver.nix
    #./xmonad.nix
  ];
}
