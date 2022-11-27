{ config, pkgs, ... }:

{
  imports = [ ./design.nix ./media.nix ./telecom.nix ./utilities.nix ];
}
