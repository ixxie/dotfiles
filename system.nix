{ pkgs, ... }:

{
  # host
  system.stateVersion = "24.05";
  networking.hostName = "contingent";
  security.sudo.wheelNeedsPassword = false;
  networking.enableIPv6 = true;

  boot = {
    # Use latest kernel
    kernelPackages = pkgs.linuxPackages_latest;
    # Use the gummiboot efi boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

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
}
