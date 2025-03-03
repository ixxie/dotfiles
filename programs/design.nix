{
  pkgs,
  ...
}:

{
  environment = {
    systemPackages = with pkgs; [
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
  };

  fonts.packages = with pkgs; [
    source-code-pro
    powerline-fonts
    inter
    google-fonts
  ];
}
