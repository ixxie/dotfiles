{ config, pkgs, ... }:

{
  imports = [ ./gnome.nix ./plasma.nix ./xserver.nix ./xmonad.nix ];
}
