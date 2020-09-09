{ config, pkgs, ... }:

{
  imports = [ ./xserver.nix ./gnome.nix ./xmonad.nix ];
}
