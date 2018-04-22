{ config, pkgs, ... }: 

{
    imports =
    [
      ./base.nix
    #  ./fed.nix
      ./sci.nix
      ./gnome.nix
    ];
}
