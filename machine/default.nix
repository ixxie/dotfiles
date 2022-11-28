{ config, pkgs, ... }:

{
  imports =
    [ ./efiboot.nix ./hardware.nix ./tweaks.nix ./audio.nix ./video.nix ];

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
