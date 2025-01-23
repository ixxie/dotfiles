{
  pkgs,
  ...
}:

{
  environment = {
    # add some desktop applications
    systemPackages = with pkgs; [
      krita
      inkscape
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
