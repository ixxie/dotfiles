{ config, pkgs, lib, ... }:

with lib; {
  environment = {
    # add some desktop applications
    systemPackages = with pkgs; [ krita inkscape ffmpeg pdftk ];
  };

  fonts.fonts = with pkgs; [
    source-code-pro
    powerline-fonts
    font-awesome_5
    inter
    google-fonts
  ];
}
