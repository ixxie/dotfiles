{ config, pkgs, lib, ... }:

with lib; {
  environment = {
    systemPackages = with pkgs; [
      firefox
      chromium
      signal-desktop
      element-desktop
      discord
    ];
  };
}
