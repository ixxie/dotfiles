{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./efiboot.nix
    ./audio.nix
    ./desktop.nix
    ./nix.nix
  ];
  system.stateVersion = "24.05";
  networking.hostName = "contingent";
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_IE.UTF-8";
  environment.variables.EDITOR = "hx";

  # enable the swap device
  # swapDevices = [{ label = "swap"; }];

  # firmware support
  nixpkgs.config.allowUnfree = true;
}
