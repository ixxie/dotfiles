{ config, pkgs, ... }: 

{
  imports = [
    ./gnome.nix
    ./xserver.nix
    ./xmonad.nix
  ];
}