{ config, pkgs, lib, ... }:

with lib; {
  config = mkIf (config.desk != "none") {
    environment = {
      # add some desktop applications
      systemPackages = with pkgs; [
        firefox
        firefox-devedition-bin
        chromium
        signal-desktop
        mailspring
      ];
    };
  };
}
