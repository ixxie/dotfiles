{ config, pkgs, lib, ... }:

with lib; {
  environment = {
    # add some desktop applications
    systemPackages = with pkgs; [
      spotify
      transmission-gtk
      vlc
      evince
      audacity
    ];
  };
}
