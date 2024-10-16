{ pkgs, ... }:
{

  # Use the gummiboot efi boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
