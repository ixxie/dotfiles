{ config, pkgs, lib, ... }:

with lib; {
  environment = {
    # add some desktop applications
    systemPackages = with pkgs; [
      wget
      unzip
      dig
      p7zip
      rar
      gparted
      simple-scan
      xclip
      lsof
    ];
  };
  networking.enableIPv6 = false;
}
