{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./efiboot.nix
    ./tweaks.nix
    ./audio.nix
    ./desktop.nix
    ./nix.nix
  ];
  system.stateVersion = "22.11";
  networking.hostName = "meso";
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_IE.utf8";
  environment.variables.EDITOR = "hx";
}
