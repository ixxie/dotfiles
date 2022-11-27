{ config, pkgs, lib, ... }:

with lib; {
  environment = {
    # add some desktop applications
    systemPackages = with pkgs; [
      firefox
      firefox-devedition-bin
      chromium
      signal-desktop
      slack
    ];
  };
}
