{ config, pkgs, ... }:

{
  imports = [ ./efiboot.nix ./hardware.nix ./tweaks.nix ./gpu.nix ];
}
