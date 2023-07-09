{ config, pkgs, lib, ... }:

{
  environment = {
    # add some desktop applications
    systemPackages = with pkgs; [
      blender
      krita
      inkscape
      ffmpeg
      pdftk
      gnome-photos
      darktable
      imagemagick
      scribus
      libreoffice
    ];
  };

  fonts.fonts = with pkgs; [
    source-code-pro
    powerline-fonts
    inter
    google-fonts
  ];
}
