{ pkgs, ... }:

with pkgs;
{
  environment.systemPackages = [
    krita
    inkscape
    gimp-with-plugins
    ffmpeg
    pdftk
    gthumb
    imagemagick
    scribus
    libreoffice
  ];

  fonts.packages = [
    source-code-pro
    powerline-fonts
    inter
    google-fonts
  ];
}
