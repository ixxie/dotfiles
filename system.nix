{pkgs, inputs, ...}: let
  label = builtins.getEnv "NIXOS_LABEL";
in {
  imports = [inputs.sops-nix.nixosModules.sops];
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/home/ixxie/.config/sops/age/keys.txt";
  };
  # host
  system.stateVersion = "24.05";
  system.nixos.label = if label != "" then label else "unlabeled";
  networking = {
    hostName = "contingent";
    networkmanager.enable = true;
    enableIPv6 = true;
  };
  security.sudo.wheelNeedsPassword = false;

  boot = {
    # Use latest kernel
    kernelPackages = pkgs.linuxPackages_latest;
    # Use the gummiboot efi boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  services.printing.enable = true;

  # environment
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_IE.UTF-8";

  # nix-ld for running unpatched binaries
  programs.nix-ld.enable = true;

  # enable swap file
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 64 * 1024;
    }
  ];
}
