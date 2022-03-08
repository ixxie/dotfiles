{ config, pkgs, ... }:

{
  imports = [ ./efiboot.nix ./hardware.nix ./tweaks.nix ./gpu.nix ];

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
