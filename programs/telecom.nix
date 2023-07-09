{ config, pkgs, lib, ... }:

with lib; {
  environment = {
    systemPackages = with pkgs; [
      firefox
      firefox-devedition-bin
      chromium
      signal-desktop
      element-desktop
      protonvpn-gui
      protonvpn-cli
    ];
  };
}
