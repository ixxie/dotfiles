{ config, pkgs, ... }: 

{
    imports =
    [
      ./base.nix
      ./tech.nix
      ./gnome.nix
    ];
}
