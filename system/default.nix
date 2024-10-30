{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./efiboot.nix
    ./audio.nix
    ./desktop.nix
    ./fonts.nix
    ./framework.nix
    ./nix.nix
  ];
  # host
  system.stateVersion = "24.05";
  networking.hostName = "contingent";

  # kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # environment
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_IE.UTF-8";
  environment.variables.EDITOR = "hx";

  # enable swap file
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 64 * 1024;
    }
  ];

  # firmware support
  nixpkgs.config.allowUnfree = true;
}
